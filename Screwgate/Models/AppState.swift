import Foundation
import Combine

// MARK: - Karabiner daemon status

enum KarabinerStatus: Equatable {
    case unknown
    case notInstalled
    case installed
    case running

    var description: String {
        switch self {
        case .unknown:      return "Checking…"
        case .notInstalled: return "Karabiner-Elements not installed"
        case .installed:    return "Installed (not running)"
        case .running:      return "Running"
        }
    }

    var isInstalled: Bool { self == .installed || self == .running }
    var isRunning:   Bool { self == .running }
}

// MARK: - App state

@MainActor
class AppState: ObservableObject {
    @Published var hyperKey: HyperKey = .capsLock {
        didSet { saveToDefaults() }
    }
    @Published var keyboardLayout: KeyboardLayout = .sixtyFive {
        didSet { saveToDefaults() }
    }

    // Direct Hyper+key bindings (no sublayer needed)
    @Published var layers: [Layer] = []

    // Sublayer groups (Hyper+key → sublayer → key → action)
    @Published var sublayers: [Sublayer] = []

    @Published var karabinerStatus: KarabinerStatus = .unknown
    @Published var statusMessage: String = ""
    @Published var showSuccess: Bool = false

    private let defaults = UserDefaults.standard

    init() {
        loadFromDefaults()
        if layers.isEmpty && sublayers.isEmpty {
            applyPreset(Presets.xeind)
        }
        Task { await refreshKarabinerStatus() }
    }

    // MARK: - Preset

    func applyPreset(_ preset: Preset) {
        hyperKey  = preset.hyperKey
        layers    = preset.layers
        sublayers = preset.sublayers
        saveToDefaults()
    }

    // MARK: - Layer CRUD

    func addLayer(_ layer: Layer) {
        layers.append(layer)
        saveToDefaults()
    }

    func updateLayer(_ layer: Layer) {
        guard let idx = layers.firstIndex(where: { $0.id == layer.id }) else { return }
        layers[idx] = layer
        saveToDefaults()
    }

    func deleteLayer(id: UUID) {
        layers.removeAll { $0.id == id }
        saveToDefaults()
    }

    func moveLayers(from: IndexSet, to: Int) {
        layers.move(fromOffsets: from, toOffset: to)
        saveToDefaults()
    }

    // MARK: - Sublayer CRUD

    func addSublayer(_ sublayer: Sublayer) {
        sublayers.append(sublayer)
        saveToDefaults()
    }

    func updateSublayer(_ sublayer: Sublayer) {
        guard let idx = sublayers.firstIndex(where: { $0.id == sublayer.id }) else { return }
        sublayers[idx] = sublayer
        saveToDefaults()
    }

    func deleteSublayer(id: UUID) {
        sublayers.removeAll { $0.id == id }
        saveToDefaults()
    }

    func moveSublayers(from: IndexSet, to: Int) {
        sublayers.move(fromOffsets: from, toOffset: to)
        saveToDefaults()
    }

    // MARK: - Binding CRUD (inside a sublayer)

    func addBinding(_ binding: KeyBinding, to sublayerID: UUID) {
        guard let idx = sublayers.firstIndex(where: { $0.id == sublayerID }) else { return }
        sublayers[idx].bindings.append(binding)
        saveToDefaults()
    }

    func updateBinding(_ binding: KeyBinding, in sublayerID: UUID) {
        guard let sIdx = sublayers.firstIndex(where: { $0.id == sublayerID }),
              let bIdx = sublayers[sIdx].bindings.firstIndex(where: { $0.id == binding.id })
        else { return }
        sublayers[sIdx].bindings[bIdx] = binding
        saveToDefaults()
    }

    func deleteBinding(id: UUID, from sublayerID: UUID) {
        guard let sIdx = sublayers.firstIndex(where: { $0.id == sublayerID }) else { return }
        sublayers[sIdx].bindings.removeAll { $0.id == id }
        saveToDefaults()
    }

    func moveBindings(from: IndexSet, to: Int, in sublayerID: UUID) {
        guard let sIdx = sublayers.firstIndex(where: { $0.id == sublayerID }) else { return }
        sublayers[sIdx].bindings.move(fromOffsets: from, toOffset: to)
        saveToDefaults()
    }

    // MARK: - Persistence

    func saveToDefaults() {
        defaults.set(hyperKey.rawValue,      forKey: "hyperKey")
        defaults.set(keyboardLayout.rawValue, forKey: "keyboardLayout")
        if let data = try? JSONEncoder().encode(layers)    { defaults.set(data, forKey: "layers") }
        if let data = try? JSONEncoder().encode(sublayers) { defaults.set(data, forKey: "sublayers") }
    }

    func loadFromDefaults() {
        if let raw = defaults.string(forKey: "hyperKey"), let hk = HyperKey(rawValue: raw) {
            hyperKey = hk
        }
        if let raw = defaults.string(forKey: "keyboardLayout"), let kl = KeyboardLayout(rawValue: raw) {
            keyboardLayout = kl
        }
        if let data = defaults.data(forKey: "layers"),
           let saved = try? JSONDecoder().decode([Layer].self, from: data) {
            layers = saved
        }
        if let data = defaults.data(forKey: "sublayers"),
           let saved = try? JSONDecoder().decode([Sublayer].self, from: data) {
            sublayers = saved
        }
    }

    // MARK: - Karabiner

    func refreshKarabinerStatus() async {
        let status = await Task.detached(priority: .background) {
            KarabinerService.checkStatus()
        }.value
        karabinerStatus = status
    }

    // MARK: - Apply config

    func applyConfig() {
        guard !layers.isEmpty || !sublayers.isEmpty else {
            setStatus("Add at least one binding before applying.", success: false)
            return
        }

        let config = ConfigGenerator.generate(hyperKey: hyperKey, layers: layers, sublayers: sublayers)

        do {
            try ConfigWriter.write(config)
            try ConfigWriter.restartDaemon()
            setStatus("Config applied!", success: true)
        } catch {
            setStatus("Error: \(error.localizedDescription)", success: false)
        }
    }

    private func setStatus(_ message: String, success: Bool) {
        statusMessage = message
        showSuccess   = success
        if success {
            Task {
                try? await Task.sleep(for: .seconds(3))
                statusMessage = ""
                showSuccess   = false
            }
        }
    }
}
