import AppKit
import Combine
import SwiftUI
import UserNotifications

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    private var statusItem: NSStatusItem?
    private var notchController: NotchPanelController?
    private var reminderController: ReminderPanelController?
    private var cancellables = Set<AnyCancellable>()
    private weak var model: EyeTimerModel?
    private var previousMode: TimerMode = .idle
    private var appBeforeBreak: NSRunningApplication?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        UNUserNotificationCenter.current().delegate = self
    }

    func configure(with model: EyeTimerModel) {
        guard self.model == nil else { return }
        self.model = model
        configureStatusItem(model: model)
        notchController = NotchPanelController(model: model)
        reminderController = ReminderPanelController(model: model)
        observeStatusTitle(model: model)
        observeModeChanges(model: model)
    }

    private func configureStatusItem(model: EyeTimerModel) {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.image = NSImage(systemSymbolName: "eye", accessibilityDescription: "LookAway")
        item.button?.imagePosition = .imageLeading
        item.button?.title = " \(formattedTime(model.displayRemaining))"

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Show LookAway", action: #selector(showMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Start / Pause", action: #selector(toggleTimer), keyEquivalent: ""))
        menu.addItem(.separator())
        menu.addItem(NSMenuItem(title: "Quit LookAway", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        item.menu = menu
        statusItem = item
    }

    private func observeStatusTitle(model: EyeTimerModel) {
        model.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self, weak model] _ in
                guard let self, let model else { return }
                self.statusItem?.button?.title = " \(formattedTime(model.displayRemaining))"
            }
            .store(in: &cancellables)
    }

    private func observeModeChanges(model: EyeTimerModel) {
        model.$mode
            .receive(on: RunLoop.main)
            .sink { [weak self] mode in
                guard let self else { return }

                if mode == .prompt {
                    self.rememberCurrentApp()
                }

                if mode == .resting && self.previousMode != .resting {
                    self.showMainWindow()
                }

                if self.previousMode == .resting && mode == .running {
                    self.restorePreviousApp()
                }

                self.previousMode = mode
            }
            .store(in: &cancellables)
    }

    @objc private func showMainWindow() {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows where window.title == "LookAway" {
            window.makeKeyAndOrderFront(nil)
            return
        }
    }

    @objc private func toggleTimer() {
        model?.toggle()
    }

    private func rememberCurrentApp() {
        guard let frontmost = NSWorkspace.shared.frontmostApplication else { return }
        let currentBundleID = Bundle.main.bundleIdentifier

        if frontmost.bundleIdentifier != currentBundleID {
            appBeforeBreak = frontmost
        }
    }

    private func restorePreviousApp() {
        guard let app = appBeforeBreak, !app.isTerminated else { return }
        appBeforeBreak = nil
        app.activate(options: [])
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let actionIdentifier = response.actionIdentifier
        await MainActor.run {
            self.model?.handleNotificationAction(actionIdentifier)
        }
    }
}
