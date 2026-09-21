import SwiftUI

@main
struct EyeAppMac: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var model = EyeTimerModel()

    var body: some Scene {
        WindowGroup("LookAway") {
            ContentView()
                .environmentObject(model)
                .preferredColorScheme(model.appearance.colorScheme)
                .frame(minWidth: 760, minHeight: 560)
                .onAppear {
                    appDelegate.configure(with: model)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            CommandGroup(replacing: .newItem) {}
        }
    }
}
