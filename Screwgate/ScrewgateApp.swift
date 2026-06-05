import SwiftUI

@main
struct ScrewgateApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                // NavigationSplitView needs enough horizontal room for sidebar + detail
                .frame(minWidth: 700, idealWidth: 820, minHeight: 440, idealHeight: 560)
        }
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}   // single-window app
        }
    }
}
