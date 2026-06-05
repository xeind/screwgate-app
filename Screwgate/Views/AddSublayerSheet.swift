import SwiftUI

struct AddSublayerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var appState: AppState

    let existingSublayer: Sublayer?
    let onSave: (Sublayer) -> Void

    @State private var key: String
    @State private var name: String

    init(existingSublayer: Sublayer?, onSave: @escaping (Sublayer) -> Void) {
        self.existingSublayer = existingSublayer
        self.onSave = onSave
        _key  = State(initialValue: existingSublayer?.key ?? "")
        _name = State(initialValue: existingSublayer?.name ?? "")
    }

    private var isValid: Bool { !key.isEmpty && !name.isEmpty }

    // Warn if the key is already used
    private var keyConflict: String? {
        let existingID = existingSublayer?.id
        if let conflict = appState.sublayers.first(where: { $0.key == key && $0.id != existingID }) {
            return "Already used by sublayer \"\(conflict.name)\""
        }
        return nil
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(existingSublayer == nil ? "Add Sublayer" : "Rename Sublayer")
                .font(.title2)
                .fontWeight(.semibold)

            Text("A sublayer activates when you hold Hyper + your chosen key, then press a binding key.")
                .font(.caption)
                .foregroundColor(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            FormSection("Activation Key  (Hyper + ?)") {
                HStack(spacing: 8) {
                    TextField("e.g. b", text: $key)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .onChange(of: key) { _, val in
                            key = String(val.lowercased().prefix(1))
                        }

                    if !key.isEmpty {
                        Text("Hyper + \(KeyDisplay.symbol(for: key))")
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }

                if let conflict = keyConflict {
                    Label(conflict, systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }

            FormSection("Sublayer Name") {
                TextField("e.g. Bookmarks", text: $name)
                    .textFieldStyle(.roundedBorder)
            }

            Spacer()

            HStack {
                Button("Cancel") { dismiss() }.keyboardShortcut(.escape)
                Spacer()
                Button(existingSublayer == nil ? "Add Sublayer" : "Save") {
                    let sublayer = Sublayer(
                        id: existingSublayer?.id ?? UUID(),
                        key: key,
                        name: name,
                        bindings: existingSublayer?.bindings ?? []
                    )
                    onSave(sublayer)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!isValid || keyConflict != nil)
                .keyboardShortcut(.return)
            }
        }
        .padding(24)
        .frame(width: 380, height: 290)
    }
}
