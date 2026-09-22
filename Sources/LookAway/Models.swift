import SwiftUI

struct EyePreset: Identifiable, Equatable {
    let id: String
    let name: String
    let shortName: String
    let focusSeconds: Int
    let breakSeconds: Int
    let distanceCue: String
    let accent: Color
    let note: String
    let reminderTitle: String
    let reminderBody: String

    var cadenceMinutes: Int {
        max(1, focusSeconds / 60)
    }
}

enum TimerMode: String {
    case idle
    case running
    case paused
    case prompt
    case resting
}

enum AppAppearance: String, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        }
    }

    var colorScheme: ColorScheme {
        switch self {
        case .light: .light
        case .dark: .dark
        }
    }
}

enum ReminderSound: String, CaseIterable, Identifiable {
    case glass
    case bloom
    case soft
    case off

    var id: String { rawValue }

    var label: String {
        switch self {
        case .glass: "Glass"
        case .bloom: "Bloom"
        case .soft: "Soft"
        case .off: "Off"
        }
    }

    var systemSoundIDs: [String] {
        switch self {
        case .glass: ["Glass", "Ping", "Glass"]
        case .bloom: ["Submarine", "Ping", "Hero"]
        case .soft: ["Tink", "Pop"]
        case .off: []
        }
    }
}

enum ReminderNotification {
    static let category = "EYE_BREAK_REMINDER"
    static let startBreak = "START_EYE_BREAK"
    static let restart = "RESTART_EYE_TIMER"
    static let disable = "DISABLE_EYE_REMINDERS"
}

let defaultPresets: [EyePreset] = [
    EyePreset(
        id: "twenty",
        name: "20-20-20",
        shortName: "20-20",
        focusSeconds: 20 * 60,
        breakSeconds: 20,
        distanceCue: "20 feet away",
        accent: Color(red: 0.25, green: 0.77, blue: 0.68),
        note: "Let your gaze land on something far enough away that your eyes stop working so hard.",
        reminderTitle: "Look away for 20 seconds",
        reminderBody: "Pick a distant object, soften your focus, and blink normally."
    ),
    EyePreset(
        id: "blink",
        name: "Blink Reset",
        shortName: "Blink",
        focusSeconds: 8 * 60,
        breakSeconds: 12,
        distanceCue: "across the room",
        accent: Color(red: 0.93, green: 0.56, blue: 0.28),
        note: "Screens can make you blink less. A small pause can help your eyes feel less dry.",
        reminderTitle: "Refresh your eyes",
        reminderBody: "Close your eyes once, then blink slowly while looking past the screen."
    ),
    EyePreset(
        id: "focus",
        name: "Focus Shift",
        shortName: "Focus",
        focusSeconds: 25 * 60,
        breakSeconds: 45,
        distanceCue: "window or far wall",
        accent: Color(red: 0.48, green: 0.55, blue: 1),
        note: "Near work asks your eyes to hold the same posture. Change the distance for a moment.",
        reminderTitle: "Change focal distance",
        reminderBody: "Look from near to far a few times, then settle on one distant point."
    ),
    EyePreset(
        id: "hourly",
        name: "Hourly Decompress",
        shortName: "Hourly",
        focusSeconds: 50 * 60,
        breakSeconds: 120,
        distanceCue: "away from the desk",
        accent: Color(red: 0.86, green: 0.37, blue: 0.29),
        note: "A longer reset helps your eyes, neck, and shoulders leave screen posture together.",
        reminderTitle: "Take a fuller break",
        reminderBody: "Stand up if you can, look away, loosen your shoulders, and reset the room."
    )
]

let guideNotes = [
    "Every 20 minutes, look about 20 feet away for at least 20 seconds.",
    "Blinking matters because concentrated screen use can reduce blink rate.",
    "Glare, tiny text, and awkward monitor angles can make your eyes work harder."
]

let reminderQuotes = [
    "The room is still here. Let your eyes remember it.",
    "A soft gaze now buys you calmer focus later.",
    "Look past the glass, blink slowly, come back lighter.",
    "Your attention can stretch without leaving the work."
]
