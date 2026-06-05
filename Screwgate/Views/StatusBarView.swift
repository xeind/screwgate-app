import SwiftUI

struct StatusBarView: View {
    @EnvironmentObject var appState: AppState
    @State private var isRefreshing = false

    var body: some View {
        HStack(spacing: 8) {
            // Status pill — click to re-poll Karabiner
            Button {
                guard !isRefreshing else { return }
                isRefreshing = true
                Task {
                    await appState.refreshKarabinerStatus()
                    isRefreshing = false
                }
            } label: {
                HStack(spacing: 5) {
                    if isRefreshing {
                        ProgressView()
                            .controlSize(.mini)
                    } else {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 7, height: 7)
                    }
                    Text(shortLabel)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(.quaternary, in: Capsule())
            }
            .buttonStyle(.plain)
            .help(tooltip)

            // Only shown when installed but daemon isn't running
            if appState.karabinerStatus == .installed {
                Button("Launch Karabiner") {
                    KarabinerService.openApp()
                }
                .font(.system(size: 11, weight: .medium))
                .buttonStyle(.bordered)
                .tint(.orange)
                .help("Start the Karabiner-Elements daemon")
            }
        }
    }

    private var shortLabel: String {
        switch appState.karabinerStatus {
        case .running:      return "Running"
        case .installed:    return "Not running"
        case .notInstalled: return "Not installed"
        case .unknown:      return "Checking…"
        }
    }

    private var statusColor: Color {
        switch appState.karabinerStatus {
        case .running:      return .green
        case .installed:    return .orange
        case .notInstalled: return .red
        case .unknown:      return .secondary
        }
    }

    private var tooltip: String {
        switch appState.karabinerStatus {
        case .running:
            return "Karabiner daemon is running — Apply takes effect immediately. Click to recheck."
        case .installed:
            return "Karabiner is installed but the daemon isn't running. Click Launch, or hit Apply — it starts automatically."
        case .notInstalled:
            return "Karabiner-Elements is not installed. Download from karabiner-elements.pqrs.org"
        case .unknown:
            return "Polling Karabiner status… Click to retry."
        }
    }
}
