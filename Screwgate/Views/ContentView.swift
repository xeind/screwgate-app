import SwiftUI

// MARK: - Sidebar section model

enum SidebarSection: Hashable {
    case directBindings
    case sublayer(UUID)
}

// MARK: - Root window

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedSection: SidebarSection? = .none
    @State private var columnVisibility: NavigationSplitViewVisibility = .all

    // Sheet / dialog state
    @State private var showAddLayer       = false
    @State private var showAddSublayer    = false
    @State private var editingLayer: Layer?              = nil
    @State private var editingBinding: BindingEditItem?  = nil
    @State private var editingSublayer: Sublayer?         = nil
    @State private var addBindingToSublayer: SublayerIDItem? = nil
    @State private var confirmPreset: Preset?             = nil

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(
                selectedSection: $selectedSection,
                onAddSublayer: { showAddSublayer = true },
                onEditSublayer: { editingSublayer = $0 },
                onAddLayer: { showAddLayer = true }
            )
            .navigationSplitViewColumnWidth(min: 180, ideal: 210, max: 260)
        } detail: {
            DetailView(
                section: selectedSection,
                onAddBinding: { id, key in addBindingToSublayer = SublayerIDItem(id: id, prefillKey: key) },
                onEditBinding: { b, sid in editingBinding = BindingEditItem(binding: b, sublayerID: sid) },
                onEditLayer: { editingLayer = $0 }
            )
        }
        .navigationTitle("Screwgate")
        .toolbar { toolbarContent }

        // ── Sheets ───────────────────────────────────────────────────────
        .sheet(isPresented: $showAddLayer) {
            let usedKeys = Set(appState.layers.map { $0.triggerKey })
            AddLayerSheet(existingLayer: nil, existingKeys: usedKeys) { appState.addLayer($0) }
        }
        .sheet(item: $editingLayer) { layer in
            let usedKeys = Set(appState.layers.filter { $0.id != layer.id }.map { $0.triggerKey })
            AddLayerSheet(existingLayer: layer, existingKeys: usedKeys) { appState.updateLayer($0) }
        }
        .sheet(isPresented: $showAddSublayer) {
            AddSublayerSheet(existingSublayer: nil) { appState.addSublayer($0) }
                .environmentObject(appState)
        }
        .sheet(item: $editingSublayer) { sub in
            AddSublayerSheet(existingSublayer: sub) { appState.updateSublayer($0) }
                .environmentObject(appState)
        }
        .sheet(item: $addBindingToSublayer) { item in
            if let sub = appState.sublayers.first(where: { $0.id == item.id }) {
                let usedKeys = Set(sub.bindings.map { $0.triggerKey })
                AddBindingSheet(
                    existingBinding: nil,
                    sublayerName: sub.name,
                    sublayerKey: sub.key,
                    existingKeys: usedKeys,
                    prefillKey: item.prefillKey
                ) {
                    appState.addBinding($0, to: item.id)
                }
            }
        }
        .sheet(item: $editingBinding) { item in
            if let sub = appState.sublayers.first(where: { $0.id == item.sublayerID }) {
                let usedKeys = Set(sub.bindings.filter { $0.id != item.binding.id }.map { $0.triggerKey })
                AddBindingSheet(
                    existingBinding: item.binding,
                    sublayerName: sub.name,
                    sublayerKey: sub.key,
                    existingKeys: usedKeys
                ) { appState.updateBinding($0, in: item.sublayerID) }
            }
        }

        // ── Preset confirmation ───────────────────────────────────────────
        .confirmationDialog(
            confirmPreset.map { "Load \"\($0.name)\"?" } ?? "",
            isPresented: Binding(
                get: { confirmPreset != nil },
                set: { if !$0 { confirmPreset = nil } }
            ),
            titleVisibility: .visible
        ) {
            if let preset = confirmPreset {
                Button("Load — Replace Current Config", role: .destructive) {
                    appState.applyPreset(preset)
                    selectedSection = appState.sublayers.first.map { .sublayer($0.id) }
                    confirmPreset = nil
                }
            }
            Button("Cancel", role: .cancel) { confirmPreset = nil }
        } message: {
            Text("This replaces all your current bindings.")
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // ── Status + Presets + Apply (trailing) ────────────────
        ToolbarItemGroup(placement: .primaryAction) {
            StatusBarView()
                .padding(.trailing, 4)

            if !appState.statusMessage.isEmpty {
                Label(
                    appState.statusMessage,
                    systemImage: appState.showSuccess
                        ? "checkmark.circle.fill"
                        : "exclamationmark.circle.fill"
                )
                .font(.caption)
                .foregroundColor(appState.showSuccess ? .green : .red)
                .animation(.easeInOut, value: appState.statusMessage)
                .transition(.opacity)
            }

            Menu {
                ForEach(Presets.all) { preset in
                    Button {
                        confirmPreset = preset
                    } label: {
                        Label(preset.name, systemImage: "tray.and.arrow.down")
                        Text(preset.description)
                    }
                }
            } label: {
                Label("Presets", systemImage: "tray.and.arrow.down")
            }
            .help("Load a preset — replaces current config")

            Button {
                appState.applyConfig()
            } label: {
                Label("Apply", systemImage: "checkmark")
                    .fontWeight(.medium)
            }
            .buttonStyle(.borderedProminent)
            .disabled((appState.layers.isEmpty && appState.sublayers.isEmpty) || !appState.karabinerStatus.isInstalled)
            .help(applyTooltip)
        }
    }

    private var applyTooltip: String {
        if appState.karabinerStatus == .notInstalled { return "Karabiner-Elements is not installed" }
        if appState.layers.isEmpty && appState.sublayers.isEmpty { return "Add at least one binding" }
        return "Write karabiner.json and restart daemon"
    }
}

// MARK: - Identifiable wrappers for sheet(item:)

struct BindingEditItem: Identifiable {
    var id: UUID { binding.id }
    let binding: KeyBinding
    let sublayerID: UUID
}

struct SublayerIDItem: Identifiable {
    let id: UUID
    var prefillKey: String? = nil
}

