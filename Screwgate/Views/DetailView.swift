import SwiftUI

// MARK: - Detail pane

struct DetailView: View {
    @EnvironmentObject var appState: AppState
    let section: SidebarSection?
    let onAddBinding: (UUID, String?) -> Void
    let onEditBinding: (KeyBinding, UUID) -> Void
    let onEditLayer: (Layer) -> Void

    var body: some View {
        Group {
            switch section {
            case .none:
                emptySelection

            case .directBindings:
                DirectBindingsDetail(onEditLayer: onEditLayer)

            case .sublayer(let id):
                if let sublayer = appState.sublayers.first(where: { $0.id == id }) {
                    SublayerDetail(
                        sublayer: sublayer,
                        onAddBinding: { key in onAddBinding(id, key) },
                        onEditBinding: { onEditBinding($0, id) }
                    )
                } else {
                    emptySelection
                }
            }
        }
    }

    private var emptySelection: some View {
        VStack(spacing: 12) {
            Image(systemName: "keyboard")
                .font(.system(size: 44))
                .foregroundColor(.secondary.opacity(0.3))
            Text("Select a sublayer")
                .font(.title3)
                .foregroundColor(.secondary)
            Text("Choose a sublayer from the sidebar, or add one with the + button.")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .navigationTitle("Screwgate")
    }
}

// MARK: - Sublayer detail

struct SublayerDetail: View {
    @EnvironmentObject var appState: AppState
    let sublayer: Sublayer
    let onAddBinding: (String?) -> Void
    let onEditBinding: (KeyBinding) -> Void

    @State private var highlightedKey: String? = nil

    private var activeKeys: Set<String> {
        Set(sublayer.bindings.map(\.triggerKey))
    }

    var body: some View {
        VStack(spacing: 0) {
            // Keyboard map header
            HStack {
                KeyboardLayoutView(
                    activeKeys: activeKeys,
                    layout: appState.keyboardLayout,
                    hyperKeyCode: appState.hyperKey.rawValue
                ) { tappedKey in
                    if activeKeys.contains(tappedKey) {
                        // Scroll to + highlight existing binding
                        withAnimation(.easeInOut(duration: 0.2)) { highlightedKey = tappedKey }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation { highlightedKey = nil }
                        }
                    } else {
                        // Open Add Binding sheet pre-filled with this key
                        onAddBinding(tappedKey)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)
                Spacer()
            }

            Divider()

            // Bindings list
            if sublayer.bindings.isEmpty {
                emptyBindings
            } else {
                bindingList
            }
        }
        .navigationTitle(sublayer.name)
        .navigationSubtitle("Hyper + \(KeyDisplay.symbol(for: sublayer.key))")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button { onAddBinding(nil) } label: {
                    Label("Add Binding", systemImage: "plus")
                }
                .help("Add a binding to this sublayer")
            }
        }
    }

    private var bindingList: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(sublayer.bindings) { binding in
                    BindingDetailRow(
                        binding: binding,
                        isHighlighted: binding.triggerKey == highlightedKey
                    ) {
                        onEditBinding(binding)
                    } onDelete: {
                        withAnimation {
                            appState.deleteBinding(id: binding.id, from: sublayer.id)
                        }
                    }
                    .id(binding.id)
                }
                .onMove { from, to in
                    appState.moveBindings(from: from, to: to, in: sublayer.id)
                }
                .onDelete { idxs in
                    guard let sIdx = appState.sublayers.firstIndex(where: { $0.id == sublayer.id }) else { return }
                    idxs.forEach { appState.deleteBinding(id: appState.sublayers[sIdx].bindings[$0].id, from: sublayer.id) }
                }
            }
            .listStyle(.inset(alternatesRowBackgrounds: true))
            .onChange(of: highlightedKey) { _, key in
                guard let key,
                      let binding = sublayer.bindings.first(where: { $0.triggerKey == key })
                else { return }
                withAnimation { proxy.scrollTo(binding.id, anchor: .center) }
            }
        }
    }

    private var emptyBindings: some View {
        VStack(spacing: 12) {
            Image(systemName: "plus.circle.dashed")
                .font(.system(size: 36))
                .foregroundColor(.secondary.opacity(0.35))
            Text("No bindings in \(sublayer.name)")
                .font(.headline)
                .foregroundColor(.secondary)
            Button { onAddBinding(nil) } label: {
                Label("Add First Binding", systemImage: "plus")
            }
            .buttonStyle(.bordered)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Direct bindings detail

struct DirectBindingsDetail: View {
    @EnvironmentObject var appState: AppState
    let onEditLayer: (Layer) -> Void

    var body: some View {
        List {
            ForEach(appState.layers) { layer in
                LayerDetailRow(layer: layer) {
                    onEditLayer(layer)
                } onDelete: {
                    withAnimation { appState.deleteLayer(id: layer.id) }
                }
            }
            .onMove { appState.moveLayers(from: $0, to: $1) }
            .onDelete { idxs in
                idxs.forEach { appState.deleteLayer(id: appState.layers[$0].id) }
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .navigationTitle("Direct Bindings")
        .navigationSubtitle("Hyper + key → action")
    }
}

// MARK: - Binding row (in detail pane)

struct BindingDetailRow: View {
    let binding: KeyBinding
    var isHighlighted: Bool = false
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            // Keycap badge
            Text(KeyDisplay.symbol(for: binding.triggerKey))
                .font(.system(size: 13, weight: .bold, design: .monospaced))
                .foregroundStyle(isHighlighted ? AnyShapeStyle(.white) : AnyShapeStyle(Color.accentColor))
                .frame(width: 38, height: 28)
                .background {
                    if isHighlighted {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor)
                        RoundedRectangle(cornerRadius: 6)
                            .fill(LinearGradient(
                                colors: [.white.opacity(0.2), .clear],
                                startPoint: .top, endPoint: .center
                            ))
                    } else {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.accentColor.opacity(0.1))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .strokeBorder(
                            isHighlighted ? Color.accentColor : Color.accentColor.opacity(0.2),
                            lineWidth: 0.5
                        )
                )
                .shadow(
                    color: isHighlighted ? Color.accentColor.opacity(0.4) : .clear,
                    radius: 4, x: 0, y: 2
                )

            VStack(alignment: .leading, spacing: 1) {
                Text(binding.bindingDescription)
                    .font(.system(size: 13, weight: .medium))
                Text(binding.displayAction)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }

            Spacer()

            HStack(spacing: 0) {
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 11))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .help("Edit")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 11))
                        .foregroundStyle(.red.opacity(0.6))
                        .frame(width: 26, height: 26)
                }
                .buttonStyle(.borderless)
                .help("Delete")
            }
        }
        .padding(.vertical, 3)
        .padding(.horizontal, 2)
        .animation(.spring(response: 0.25), value: isHighlighted)
    }
}

// MARK: - Layer row (direct bindings pane)

struct LayerDetailRow: View {
    let layer: Layer
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Text(layer.displayTrigger)
                .font(.system(.callout, design: .monospaced))
                .foregroundColor(.accentColor)
                .frame(width: 100, alignment: .leading)

            Image(systemName: "arrow.right")
                .font(.caption2)
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 2) {
                Text(layer.layerDescription).font(.body)
                Text(layer.displayAction)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 2) {
                Button(action: onEdit) {
                    Image(systemName: "pencil").font(.system(size: 12))
                }
                .buttonStyle(.borderless).help("Edit")

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 12))
                        .foregroundColor(.red.opacity(0.7))
                }
                .buttonStyle(.borderless).help("Delete")
            }
        }
        .padding(.vertical, 4)
    }
}
