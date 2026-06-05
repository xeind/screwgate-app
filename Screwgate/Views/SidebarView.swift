import SwiftUI

// MARK: - Sidebar

struct SidebarView: View {
    @EnvironmentObject var appState: AppState
    @Binding var selectedSection: SidebarSection?

    let onAddSublayer: () -> Void
    let onEditSublayer: (Sublayer) -> Void
    let onAddLayer: () -> Void

    var body: some View {
        List(selection: $selectedSection) {
            // ── Hyper Key picker ───────────────────────────────────────
            Section {
                HStack {
                    Image(systemName: "capslock.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 11))
                    Picker("Hyper Key", selection: $appState.hyperKey) {
                        ForEach(HyperKey.allCases) { key in
                            Text(key.displayName).tag(key)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.menu)
                }
                .padding(.vertical, 2)
            } header: {
                Text("Hyper Key")
            }

            // ── Direct Bindings ────────────────────────────────────────
            if !appState.layers.isEmpty {
                Section("Direct") {
                    Label("Direct Bindings", systemImage: "bolt.fill")
                        .tag(SidebarSection.directBindings)
                        .badge(appState.layers.count)
                }
            }

            // ── Sublayers ──────────────────────────────────────────────
            Section {
                ForEach(appState.sublayers) { sublayer in
                    SublayerRow(
                        sublayer: sublayer,
                        onEdit: { onEditSublayer(sublayer) },
                        onDelete: { appState.deleteSublayer(id: sublayer.id) }
                    )
                    .tag(SidebarSection.sublayer(sublayer.id))
                }
                .onMove { appState.moveSublayers(from: $0, to: $1) }
                .onDelete { idxs in
                    idxs.forEach { appState.deleteSublayer(id: appState.sublayers[$0].id) }
                }
            } header: {
                HStack {
                    Text("Sublayers")
                    Spacer()
                    Button(action: onAddSublayer) {
                        Image(systemName: "plus")
                            .font(.caption)
                    }
                    .buttonStyle(.borderless)
                    .help("Add sublayer")
                }
            }
        }
        .listStyle(.sidebar)
        .onAppear {
            // Auto-select first sublayer
            if selectedSection == nil {
                selectedSection = appState.sublayers.first.map { .sublayer($0.id) }
                    ?? (!appState.layers.isEmpty ? .directBindings : nil)
            }
        }
        .onChange(of: appState.sublayers) { _, new in
            // If selected sublayer was deleted, fall back to first
            if case .sublayer(let id) = selectedSection,
               !new.contains(where: { $0.id == id }) {
                selectedSection = new.first.map { .sublayer($0.id) }
            }
        }
        .safeAreaInset(edge: .bottom) {
            sidebarFooter
        }
    }

    private var sidebarFooter: some View {
        VStack(spacing: 0) {
            Divider()
            HStack {
                Button(action: onAddLayer) {
                    Label("Direct", systemImage: "plus")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderless)
                .help("Add a direct Hyper+key binding")

                Spacer()

                Button(action: { ConfigWriter.openConfigFolder() }) {
                    Image(systemName: "folder")
                        .font(.system(size: 11))
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
                .help("Open ~/.config/karabiner in Finder")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .background(.regularMaterial)
    }
}

// MARK: - Sublayer sidebar row

struct SublayerRow: View {
    let sublayer: Sublayer
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 6) {
            Label {
                Text(sublayer.name)
                    .font(.system(size: 13, weight: .medium))
            } icon: {
                Text(KeyDisplay.symbol(for: sublayer.key))
                    .font(.system(size: 10, weight: .black, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background {
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.accentColor)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .top, endPoint: .bottom
                            ))
                    }
                    .shadow(color: Color.accentColor.opacity(0.4), radius: 2, x: 0, y: 1)
            }

            Spacer()
        }
        .badge(sublayer.bindings.count)
        .contextMenu {
            Button("Rename…", action: onEdit)
            Divider()
            Button("Delete", role: .destructive, action: onDelete)
        }
    }
}
