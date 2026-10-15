import SwiftUI

@main
struct LookAwayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = EyeTimerModel()
    @Environment(\.openWindow) private var openWindow

    var body: some Scene {
        WindowGroup("LookAway", id: "main") {
            ContentView()
                .environmentObject(model)
                .preferredColorScheme(model.appearance.colorScheme)
                .frame(minWidth: 760, minHeight: 560)
                .onAppear {
                    appDelegate.configure(with: model) {
                        openWindow(id: "main")
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
