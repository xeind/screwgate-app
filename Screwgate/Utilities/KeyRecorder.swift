import AppKit
import Combine

/// Listens for the next key press globally and exposes it as a Karabiner key_code string.
@MainActor
class KeyRecorder: ObservableObject {
    @Published var capturedKey: String? = nil

    private var monitor: Any?

    func startRecording() {
        capturedKey = nil
        monitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return }
            let keyCode = KeyCodeMap.karabinerCode(for: event.keyCode)
                ?? event.characters?.lowercased().first.map(String.init)
            Task { @MainActor in
                self.capturedKey = keyCode
                self.stopRecording()
            }
        }
    }

    func stopRecording() {
        if let m = monitor {
            NSEvent.removeMonitor(m)
            monitor = nil
        }
    }

    deinit {
        if let m = monitor { NSEvent.removeMonitor(m) }
    }
}
