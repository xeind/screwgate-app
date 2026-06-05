import SwiftUI
import AppKit
import UniformTypeIdentifiers

// MARK: - Add / Edit a DIRECT binding (Layer)

struct AddLayerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let existingLayer: Layer?
    let onSave: (Layer) -> Void

    @State private var triggerKey: String
    @State private var actionType: ActionType
    @State private var actionValue: String
    @State private var actionModifiers: Set<String>
    @State private var layerDescription: String
    @State private var isRecording = false
    @State private var showAppPicker = false
    @StateObject private var keyRecorder = KeyRecorder()

    init(existingLayer: Layer?, onSave: @escaping (Layer) -> Void) {
        self.existingLayer = existingLayer
        self.onSave = onSave
        _triggerKey       = State(initialValue: existingLayer?.triggerKey ?? "")
        _actionType       = State(initialValue: existingLayer?.actionType ?? .keyPress)
        _actionValue      = State(initialValue: existingLayer?.actionValue ?? "")
        _actionModifiers  = State(initialValue: Set(existingLayer?.actionModifiers ?? []))
        _layerDescription = State(initialValue: existingLayer?.layerDescription ?? "")
    }

    private var isValid: Bool { !triggerKey.isEmpty && !actionValue.isEmpty }

    var body: some View {
        BindingFormView(
            title: existingLayer == nil ? "Add Direct Binding" : "Edit Direct Binding",
            subtitle: "Hyper + key → action (no sublayer needed)",
            triggerKey: $triggerKey,
            actionType: $actionType,
            actionValue: $actionValue,
            actionModifiers: $actionModifiers,
            description: $layerDescription,
            isRecording: $isRecording,
            showAppPicker: $showAppPicker,
            keyRecorder: keyRecorder,
            isValid: isValid,
            saveLabel: existingLayer == nil ? "Add" : "Save"
        ) {
            let layer = Layer(
                id: existingLayer?.id ?? UUID(),
                triggerKey: triggerKey,
                actionType: actionType,
                actionValue: actionValue,
                actionModifiers: Array(actionModifiers),
                description: layerDescription
            )
            onSave(layer)
            dismiss()
        } onCancel: {
            dismiss()
        }
        .onChange(of: keyRecorder.capturedKey) { _, key in
            if let key, isRecording { triggerKey = key; isRecording = false }
        }
    }
}

// MARK: - Add / Edit a SUBLAYER BINDING

struct AddBindingSheet: View {
    @Environment(\.dismiss) private var dismiss
    let existingBinding: KeyBinding?
    let sublayerName: String
    let sublayerKey: String
    let onSave: (KeyBinding) -> Void

    @State private var triggerKey: String
    @State private var actionType: ActionType
    @State private var actionValue: String
    @State private var actionModifiers: Set<String>
    @State private var bindingDescription: String
    @State private var isRecording = false
    @State private var showAppPicker = false
    @StateObject private var keyRecorder = KeyRecorder()

    init(existingBinding: KeyBinding?, sublayerName: String, sublayerKey: String,
         prefillKey: String? = nil, onSave: @escaping (KeyBinding) -> Void) {
        self.existingBinding = existingBinding
        self.sublayerName    = sublayerName
        self.sublayerKey     = sublayerKey
        self.onSave = onSave
        _triggerKey         = State(initialValue: existingBinding?.triggerKey ?? prefillKey ?? "")
        _actionType         = State(initialValue: existingBinding?.actionType ?? .keyPress)
        _actionValue        = State(initialValue: existingBinding?.actionValue ?? "")
        _actionModifiers    = State(initialValue: Set(existingBinding?.actionModifiers ?? []))
        _bindingDescription = State(initialValue: existingBinding?.bindingDescription ?? "")
    }

    private var isValid: Bool { !triggerKey.isEmpty && !actionValue.isEmpty }

    var body: some View {
        BindingFormView(
            title: existingBinding == nil ? "Add Binding" : "Edit Binding",
            subtitle: "Hyper + \(KeyDisplay.symbol(for: sublayerKey)) → \(sublayerName) → key → action",
            triggerKey: $triggerKey,
            actionType: $actionType,
            actionValue: $actionValue,
            actionModifiers: $actionModifiers,
            description: $bindingDescription,
            isRecording: $isRecording,
            showAppPicker: $showAppPicker,
            keyRecorder: keyRecorder,
            isValid: isValid,
            saveLabel: existingBinding == nil ? "Add" : "Save"
        ) {
            let binding = KeyBinding(
                id: existingBinding?.id ?? UUID(),
                triggerKey: triggerKey,
                actionType: actionType,
                actionValue: actionValue,
                actionModifiers: Array(actionModifiers),
                description: bindingDescription
            )
            onSave(binding)
            dismiss()
        } onCancel: {
            dismiss()
        }
        .onChange(of: keyRecorder.capturedKey) { _, key in
            if let key, isRecording { triggerKey = key; isRecording = false }
        }
    }
}

// MARK: - Shared form view

struct BindingFormView: View {
    let title: String
    let subtitle: String
    @Binding var triggerKey: String
    @Binding var actionType: ActionType
    @Binding var actionValue: String
    @Binding var actionModifiers: Set<String>
    @Binding var description: String
    @Binding var isRecording: Bool
    @Binding var showAppPicker: Bool
    let keyRecorder: KeyRecorder
    let isValid: Bool
    let saveLabel: String
    let onSave: () -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.title2).fontWeight(.semibold)
                Text(subtitle).font(.caption).foregroundColor(.secondary)
            }

            // Trigger key
            FormSection("Trigger Key") {
                HStack(spacing: 8) {
                    TextField("e.g. j", text: $triggerKey)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onChange(of: triggerKey) { _, val in
                            triggerKey = String(val.lowercased().prefix(20))
                        }

                    Button(action: toggleRecording) {
                        Label(isRecording ? "Listening…" : "Record",
                              systemImage: isRecording ? "waveform.circle.fill" : "record.circle")
                            .frame(width: 95)
                    }
                    .buttonStyle(.bordered)
                    .tint(isRecording ? .red : .accentColor)

                    if !triggerKey.isEmpty {
                        Text(KeyDisplay.symbol(for: triggerKey))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Action type
            FormSection("Action Type") {
                Picker("", selection: $actionType) {
                    ForEach(ActionType.allCases) { t in Text(t.displayName).tag(t) }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                .onChange(of: actionType) { _, _ in actionValue = "" }
            }

            // Action value
            FormSection(actionValueLabel) {
                actionValueField
            }

            // Description
            FormSection("Description (optional)") {
                TextField("e.g. Arrow Down", text: $description)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            HStack {
                Button("Cancel", action: onCancel).keyboardShortcut(.escape)
                Spacer()
                Button(saveLabel, action: onSave)
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)
                    .keyboardShortcut(.return)
            }
        }
        .padding(24)
        .frame(width: 480, height: 420)
    }

    @ViewBuilder
    private var actionValueField: some View {
        switch actionType {
        case .keyPress:
            VStack(alignment: .leading, spacing: 8) {
                Picker("Key", selection: $actionValue) {
                    Text("Select key…").tag("")
                    ForEach(KeyCodeMap.commonKeys, id: \.self) { Text($0).tag($0) }
                }
                .frame(width: 220)

                Text("Additional modifiers").font(.caption).foregroundColor(.secondary)

                HStack(spacing: 6) {
                    ForEach([("left_command","⌘"),("left_option","⌥"),("left_control","⌃"),("left_shift","⇧")], id: \.0) { mod, sym in
                        Toggle(isOn: Binding(
                            get: { actionModifiers.contains(mod) },
                            set: { on in if on { actionModifiers.insert(mod) } else { actionModifiers.remove(mod) } }
                        )) { Text(sym) }
                        .toggleStyle(.button)
                        .font(.system(.body, design: .monospaced))
                    }
                }
            }

        case .url:
            VStack(alignment: .leading, spacing: 6) {
                TextField("https://example.com", text: $actionValue)
                    .textFieldStyle(.roundedBorder)
                Text("Opens in your default browser. Works with any URL scheme (mailto:, raycast://, etc.)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

        case .openApp:
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    TextField("/Applications/Messages.app", text: $actionValue)
                        .textFieldStyle(.roundedBorder)
                    Button("Browse…") { pickApp() }.buttonStyle(.bordered)
                    Button("Pick…") { showAppPicker = true }.buttonStyle(.bordered)
                }
                if !actionValue.isEmpty {
                    Text(URL(fileURLWithPath: actionValue).deletingPathExtension().lastPathComponent)
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showAppPicker) {
                AppPickerSheet { path in
                    actionValue = path
                }
            }

        case .shellCommand:
            VStack(alignment: .leading, spacing: 6) {
                TextField("e.g. open -a 'Spotify.app'", text: $actionValue)
                    .textFieldStyle(.roundedBorder)
                Text("Any shell command. Use open -a 'App.app', open https://..., or anything else.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var actionValueLabel: String {
        switch actionType {
        case .keyPress:     return "Key"
        case .url:          return "URL"
        case .openApp:      return "Application"
        case .shellCommand: return "Shell Command"
        }
    }

    private func toggleRecording() {
        if isRecording { isRecording = false; keyRecorder.stopRecording() }
        else           { isRecording = true;  keyRecorder.startRecording() }
    }

    private func pickApp() {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.begin { response in
            if response == .OK, let url = panel.url { actionValue = url.path }
        }
    }
}

// MARK: - Form section label helper

struct FormSection<Content: View>: View {
    let label: String
    @ViewBuilder let content: Content

    init(_ label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label).font(.caption).foregroundColor(.secondary)
            content
        }
    }
}
