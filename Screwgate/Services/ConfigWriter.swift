import Foundation
import AppKit

enum ConfigWriterError: LocalizedError {
    case encodingFailed
    case writeFailed(String)
    case daemonRestartFailed(Int32)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode configuration."
        case .writeFailed(let msg):
            return "Failed to write config file: \(msg)"
        case .daemonRestartFailed(let code):
            return "Daemon restart failed (exit code \(code))."
        }
    }
}

struct ConfigWriter {
    // MARK: - Paths

    static var configURL: URL {
        FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".config/karabiner/karabiner.json")
    }

    static var configDirectory: URL { configURL.deletingLastPathComponent() }

    // MARK: - Write

    static func write(_ config: KarabinerConfig) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        guard let data = try? encoder.encode(config) else {
            throw ConfigWriterError.encodingFailed
        }

        do {
            try FileManager.default.createDirectory(
                at: configDirectory,
                withIntermediateDirectories: true
            )
            try data.write(to: configURL, options: .atomic)
        } catch {
            throw ConfigWriterError.writeFailed(error.localizedDescription)
        }
    }

    // MARK: - Daemon restart

    static func restartDaemon() throws {
        let label = "gui/\(getuid())/org.pqrs.karabiner.karabiner_console_user_server"
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["kickstart", "-k", label]
        process.standardOutput = Pipe()
        process.standardError  = Pipe()

        try process.run()
        process.waitUntilExit()

        guard process.terminationStatus == 0 else {
            throw ConfigWriterError.daemonRestartFailed(process.terminationStatus)
        }
    }

    // MARK: - Open folder in Finder

    static func openConfigFolder() {
        NSWorkspace.shared.open(configDirectory)
    }
}
