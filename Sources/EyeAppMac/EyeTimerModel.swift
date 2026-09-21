import AppKit
import Combine
import SwiftUI
import UserNotifications

@MainActor
final class EyeTimerModel: ObservableObject {
    @Published var presets = defaultPresets
    @Published var selectedPresetID = "twenty" {
        didSet { resetForSelectedPreset() }
    }
    @Published var customName = "Custom Reset"
    @Published var customFocusMinutes = 18
    @Published var customBreakSeconds = 30
    @Published var sound: ReminderSound = .glass
    @Published var nativeNotifications = true
    @Published var visualReminders = true
    @Published var appearance: AppAppearance = .light
    @Published var mode: TimerMode = .idle
    @Published var focusRemaining = defaultPresets[0].focusSeconds
    @Published var breakRemaining = defaultPresets[0].breakSeconds
    @Published var completedBreaks = 0
    @Published var lastAction = "Ready when you are."
    @Published var quoteIndex = 0

    private var ticker: Timer?
    private var soundWorkItems: [DispatchWorkItem] = []

    var customPreset: EyePreset {
        EyePreset(
            id: "custom",
            name: customName.isEmpty ? "Custom Reset" : customName,
            shortName: "Custom",
            focusSeconds: max(1, customFocusMinutes) * 60,
            breakSeconds: max(5, customBreakSeconds),
            distanceCue: "your chosen distance",
            accent: ColorPalette.custom,
            note: "Tune the rhythm to match the way you work, then keep it gentle enough to actually follow.",
            reminderTitle: "Your custom eye break",
            reminderBody: "Look away from the screen and let your eyes rest."
        )
    }

    var allPresets: [EyePreset] {
        presets + [customPreset]
    }

    var activePreset: EyePreset {
        allPresets.first(where: { $0.id == selectedPresetID }) ?? presets[0]
    }

    var displayRemaining: Int {
        mode == .resting ? breakRemaining : focusRemaining
    }

    var progress: Double {
        if mode == .resting {
            return 1 - Double(breakRemaining) / Double(max(1, activePreset.breakSeconds))
        }

        return 1 - Double(focusRemaining) / Double(max(1, activePreset.focusSeconds))
    }

    init() {
        if canUseUserNotifications {
            registerNotificationActions()
            requestNotifications()
        }
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.tick()
            }
        }
    }

    func start() {
        if mode == .resting {
            mode = .resting
        } else {
            mode = .running
        }
        lastAction = "Timer started."
    }

    func pause() {
        mode = .paused
        lastAction = "Paused."
    }

    func toggle() {
        if mode == .running || mode == .resting {
            pause()
        } else {
            start()
        }
    }

    func reset() {
        mode = .idle
        focusRemaining = activePreset.focusSeconds
        breakRemaining = activePreset.breakSeconds
        lastAction = "Timer reset."
    }

    func acceptBreak() {
        cancelReminderSound()
        breakRemaining = activePreset.breakSeconds
        playBreakStartSound()
        mode = .resting
        lastAction = "Break accepted."
    }

    func skipBreak() {
        cancelReminderSound()
        focusRemaining = activePreset.focusSeconds
        mode = .running
        lastAction = "Skipped. Timer restarted."
    }

    func disableForNow() {
        cancelReminderSound()
        mode = .idle
        focusRemaining = activePreset.focusSeconds
        breakRemaining = activePreset.breakSeconds
        lastAction = "Reminders disabled for now."
    }

    func selectPreset(_ preset: EyePreset) {
        selectedPresetID = preset.id
        lastAction = "\(preset.name) selected."
    }

    func useCustom() {
        selectedPresetID = "custom"
    }

    func handleNotificationAction(_ identifier: String) {
        switch identifier {
        case ReminderNotification.startBreak:
            acceptBreak()
        case ReminderNotification.restart:
            skipBreak()
        case ReminderNotification.disable:
            disableForNow()
        default:
            break
        }
    }

    private func tick() {
        switch mode {
        case .running:
            if focusRemaining <= 1 {
                fireReminder()
            } else {
                focusRemaining -= 1
            }
        case .resting:
            if breakRemaining <= 1 {
                completedBreaks += 1
                focusRemaining = activePreset.focusSeconds
                breakRemaining = activePreset.breakSeconds
                playBreakEndSound()
                mode = .running
                lastAction = "Nice reset. Timer restarted."
            } else {
                breakRemaining -= 1
            }
        case .idle, .paused, .prompt:
            break
        }
    }

    private func fireReminder() {
        mode = .prompt
        focusRemaining = activePreset.focusSeconds
        quoteIndex = (quoteIndex + 1) % reminderQuotes.count
        lastAction = "Reminder is waiting for you."
        playReminderSound()
        sendNotificationIfAllowed()
    }

    private func resetForSelectedPreset() {
        focusRemaining = activePreset.focusSeconds
        breakRemaining = activePreset.breakSeconds
        mode = .idle
    }

    private func requestNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    private func registerNotificationActions() {
        let startBreak = UNNotificationAction(
            identifier: ReminderNotification.startBreak,
            title: "Start break",
            options: [.foreground]
        )
        let restart = UNNotificationAction(
            identifier: ReminderNotification.restart,
            title: "Restart timer",
            options: []
        )
        let disable = UNNotificationAction(
            identifier: ReminderNotification.disable,
            title: "Disable for now",
            options: [.destructive]
        )
        let category = UNNotificationCategory(
            identifier: ReminderNotification.category,
            actions: [startBreak, restart, disable],
            intentIdentifiers: [],
            options: [.customDismissAction]
        )

        UNUserNotificationCenter.current().setNotificationCategories([category])
    }

    private func sendNotificationIfAllowed() {
        guard nativeNotifications, canUseUserNotifications else { return }

        let content = UNMutableNotificationContent()
        content.title = "\(activePreset.name) break"
        content.subtitle = "Time to look at \(activePreset.distanceCue)"
        content.body = "\(activePreset.reminderBody) Choose an option to keep the rhythm."
        content.categoryIdentifier = ReminderNotification.category
        content.interruptionLevel = .timeSensitive
        content.sound = sound == .off ? nil : .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    private func playReminderSound() {
        cancelReminderSound()

        let names = sound.systemSoundIDs
        guard !names.isEmpty else { return }

        let offsets: [TimeInterval]
        switch sound {
        case .glass:
            offsets = [0, 0.18, 0.42, 1.15]
        case .bloom:
            offsets = [0, 0.34, 0.78, 1.28]
        case .soft:
            offsets = [0, 0.38]
        case .off:
            offsets = []
        }

        for (index, offset) in offsets.enumerated() {
            let item = DispatchWorkItem { [weak self] in
                guard let self, self.mode == .prompt else { return }
                NSSound(named: names[index % names.count])?.play()
            }
            soundWorkItems.append(item)
            DispatchQueue.main.asyncAfter(deadline: .now() + offset, execute: item)
        }

        if sound != .soft {
            let repeatItem = DispatchWorkItem { [weak self] in
                guard let self, self.mode == .prompt else { return }
                for (index, name) in names.prefix(2).enumerated() {
                    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.26) {
                        guard self.mode == .prompt else { return }
                        NSSound(named: name)?.play()
                    }
                }
            }
            soundWorkItems.append(repeatItem)
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0, execute: repeatItem)
        }
    }

    private func playBreakStartSound() {
        playImmediateSequence(["Ping", "Glass"], spacing: 0.18)
    }

    private func playBreakEndSound() {
        playImmediateSequence(["Glass", "Ping", "Hero"], spacing: 0.2)
    }

    private func playImmediateSequence(_ names: [String], spacing: TimeInterval) {
        guard sound != .off else { return }

        for (index, name) in names.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * spacing) {
                NSSound(named: name)?.play()
            }
        }
    }

    private func cancelReminderSound() {
        soundWorkItems.forEach { $0.cancel() }
        soundWorkItems.removeAll()
    }

    private var canUseUserNotifications: Bool {
        Bundle.main.bundleURL.pathExtension == "app"
    }
}

enum ColorPalette {
    static let custom = SwiftUI.Color(red: 0.18, green: 0.64, blue: 0.56)
}

func formattedTime(_ totalSeconds: Int) -> String {
    let minutes = totalSeconds / 60
    let seconds = totalSeconds % 60
    return "\(minutes):\(String(format: "%02d", seconds))"
}
