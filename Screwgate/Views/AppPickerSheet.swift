import SwiftUI
import AppKit

// MARK: - Searchable installed-app picker

struct AppPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (String) -> Void   // returns full .app path

    @State private var query = ""
    @State private var apps: [AppInfo] = []

    private var filtered: [AppInfo] {
        query.isEmpty ? apps : apps.filter { $0.name.localizedCaseInsensitiveContains(query) }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Choose App")
                    .font(.title3).fontWeight(.semibold)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.borderless)
                    .keyboardShortcut(.escape)
            }
            .padding([.horizontal, .top], 16)
            .padding(.bottom, 10)

            // Search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass").foregroundColor(.secondary)
                TextField("Search apps…", text: $query)
                    .textFieldStyle(.plain)
                if !query.isEmpty {
                    Button { query = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundColor(.secondary)
                    }
                    .buttonStyle(.borderless)
                }
            }
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
            .padding(.bottom, 8)

            Divider()

            // App list
            if filtered.isEmpty {
                Spacer()
                Text(apps.isEmpty ? "Scanning…" : "No apps match \"\(query)\"")
                    .foregroundColor(.secondary)
                    .font(.callout)
                Spacer()
            } else {
                List(filtered) { app in
                    Button {
                        onSelect(app.path)
                        dismiss()
                    } label: {
                        HStack(spacing: 10) {
                            Image(nsImage: app.icon)
                                .resizable()
                                .frame(width: 28, height: 28)
                            Text(app.name)
                                .foregroundColor(.primary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 340, height: 420)
        .task { apps = await AppScanner.installedApps() }
    }
}

// MARK: - App info model

struct AppInfo: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let path: String
    let icon: NSImage
}

// MARK: - Background scanner

enum AppScanner {
    static func installedApps() async -> [AppInfo] {
        await Task.detached(priority: .userInitiated) {
            let fm = FileManager.default
            let searchDirs = [
                "/Applications",
                (NSHomeDirectory() as NSString).appendingPathComponent("Applications"),
                "/System/Applications",
            ]

            var seen = Set<String>()
            var result: [AppInfo] = []

            for dir in searchDirs {
                guard let entries = try? fm.contentsOfDirectory(atPath: dir) else { continue }
                for entry in entries where entry.hasSuffix(".app") {
                    let path = (dir as NSString).appendingPathComponent(entry)
                    let name = (entry as NSString).deletingPathExtension
                    guard seen.insert(name.lowercased()).inserted else { continue }
                    let icon = NSWorkspace.shared.icon(forFile: path)
                    result.append(AppInfo(name: name, path: path, icon: icon))
                }
            }

            return result.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }.value
    }
}
