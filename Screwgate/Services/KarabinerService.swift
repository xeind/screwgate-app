import Foundation
import AppKit

struct KarabinerService {
    private static let appPath = "/Applications/Karabiner-Elements.app"
    private static let daemonLabel = "org.pqrs.karabiner.karabiner_console_user_server"

    static func checkStatus() -> KarabinerStatus {
        guard FileManager.default.fileExists(atPath: appPath) else {
            return .notInstalled
        }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/bin/launchctl")
        process.arguments = ["list", daemonLabel]
        process.standardOutput = Pipe()
        process.standardError  = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            return process.terminationStatus == 0 ? .running : .installed
        } catch {
            return .installed
        }
    }

    static func openApp() {
        NSWorkspace.shared.open(URL(fileURLWithPath: appPath))
    }

    static var downloadURL: URL {
        URL(string: "https://karabiner-elements.pqrs.org")!
    }
}
