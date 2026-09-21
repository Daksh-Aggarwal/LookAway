import SwiftUI

private enum LayoutMode {
    case full
    case compact
    case narrow

    init(width: CGFloat) {
        if width >= 1280 {
            self = .full
        } else if width >= 980 {
            self = .compact
        } else {
            self = .narrow
        }
    }

    var showsSidebar: Bool {
        self != .narrow
    }

    var sidebarWidth: CGFloat {
        self == .full ? 286 : 236
    }

    var outerPadding: CGFloat {
        switch self {
        case .full: 32
        case .compact: 24
        case .narrow: 18
        }
    }
}

struct ContentView: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        GeometryReader { proxy in
            let layout = LayoutMode(width: proxy.size.width)

            ZStack {
                AppBackground(accent: model.activePreset.accent)

                HStack(spacing: 0) {
                    if layout.showsSidebar {
                        SidebarView(layout: layout)
                            .frame(width: layout.sidebarWidth)
                    }

                    MainTimerView(layout: layout)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }

                if model.mode == .resting {
                    BreakBanner()
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .foregroundStyle(Design.ink)
            .animation(.smooth(duration: 0.24), value: model.mode)
        }
    }
}

private struct AppBackground: View {
    let accent: Color

    var body: some View {
        ZStack {
            LinearGradient(
                stops: [
                    .init(color: Design.canvasWarm, location: 0),
                    .init(color: Design.canvas, location: 0.48),
                    .init(color: Design.canvasCool, location: 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(accent.opacity(0.11))
                .frame(width: 420, height: 420)
                .blur(radius: 74)
                .offset(x: 300, y: -230)
        }
        .ignoresSafeArea()
    }
}

private struct SidebarView: View {
    @EnvironmentObject private var model: EyeTimerModel
    let layout: LayoutMode

    var body: some View {
        VStack(alignment: .leading, spacing: layout == .full ? 24 : 18) {
            BrandLockup(compact: layout == .compact)

            VStack(spacing: 8) {
                ForEach(model.allPresets) { preset in
                    PresetButton(preset: preset, isSelected: preset.id == model.activePreset.id, compact: layout == .compact)
                }
            }

            Spacer(minLength: 10)

            NotePanel()
        }
        .padding(layout == .full ? 22 : 18)
        .background(Design.sidebar)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(Design.stroke)
                .frame(width: 1)
        }
    }
}

private struct BrandLockup: View {
    @EnvironmentObject private var model: EyeTimerModel
    let compact: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "eye")
                .font(.system(size: compact ? 19 : 22, weight: .semibold))
                .foregroundStyle(Design.ink)
                .frame(width: compact ? 40 : 44, height: compact ? 40 : 44)
                .background(model.activePreset.accent.opacity(0.28), in: RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 3) {
                    Text("LookAway")
                        .font(.system(size: compact ? 18 : 20, weight: .bold))
                        .foregroundStyle(Design.ink)
                        .lineLimit(1)
                Text("Eye break timer")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(Design.muted)
                    .lineLimit(1)
            }
        }
    }
}

private struct PresetButton: View {
    @EnvironmentObject private var model: EyeTimerModel
    let preset: EyePreset
    let isSelected: Bool
    let compact: Bool

    var body: some View {
        Button {
            model.selectPreset(preset)
        } label: {
            HStack(spacing: compact ? 10 : 12) {
                Capsule()
                    .fill(preset.accent)
                    .frame(width: 10, height: compact ? 30 : 34)

                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.system(size: compact ? 13 : 14, weight: .bold))
                        .foregroundStyle(Design.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                    Text("\(preset.cadenceMinutes) min / \(preset.breakSeconds) sec")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(Design.muted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .frame(minHeight: compact ? 56 : 62)
            .padding(.horizontal, compact ? 10 : 12)
            .background(isSelected ? Design.card.opacity(0.95) : .clear, in: RoundedRectangle(cornerRadius: 8))
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? preset.accent.opacity(0.42) : .clear, lineWidth: 1.5)
            }
            .shadow(color: isSelected ? .black.opacity(0.07) : .clear, radius: 14, y: 8)
        }
        .buttonStyle(.plain)
    }
}

private struct NotePanel: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Note", systemImage: "sparkles")
                .panelTitleStyle()

            Text(guideNotes[model.completedBreaks % guideNotes.count])
                .font(.system(size: 13))
                .foregroundStyle(Design.bodyText)
                .lineSpacing(3)
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .panelStyle()
    }
}

private struct MainTimerView: View {
    let layout: LayoutMode
    @State private var showsSettings = false

    var body: some View {
        VStack(spacing: layout == .full ? 22 : 16) {
            HeaderView(showPresetStrip: layout == .narrow, showsSettingsButton: layout != .full) {
                showsSettings = true
            }

            GeometryReader { proxy in
                if layout == .full {
                    HStack(alignment: .top, spacing: 22) {
                        TimerPanel(layout: layout)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .layoutPriority(1)

                        SettingsColumn()
                            .frame(width: min(326, proxy.size.width * 0.32))
                    }
                } else {
                    TimerPanel(layout: layout)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            BottomStrip(layout: layout)
        }
        .padding(layout.outerPadding)
        .sheet(isPresented: $showsSettings) {
            SettingsSheet()
        }
    }
}

private struct HeaderView: View {
    @EnvironmentObject private var model: EyeTimerModel
    let showPresetStrip: Bool
    let showsSettingsButton: Bool
    let onSettings: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: showPresetStrip ? 14 : 0) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Current rhythm")
                        .eyebrowStyle()
                    Text(model.activePreset.name)
                        .font(.system(size: showPresetStrip ? 26 : 30, weight: .bold))
                        .foregroundStyle(Design.ink)
                        .lineLimit(1)
                        .minimumScaleFactor(0.76)
                }

                Spacer()

                HStack(spacing: 10) {
                    if showsSettingsButton {
                        Button(action: onSettings) {
                            Image(systemName: "slider.horizontal.3")
                                .frame(width: 40, height: 40)
                        }
                        .iconActionStyle()
                        .help("Settings")
                    }

                    StatusPill()
                }
            }

            if showPresetStrip {
                HorizontalPresetStrip()
            }
        }
    }
}

private struct StatusPill: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(model.mode == .running || model.mode == .resting ? model.activePreset.accent : Design.muted.opacity(0.7))
                .frame(width: 8, height: 8)
            Text(model.mode.rawValue)
                .font(.system(size: 12, weight: .bold))
                .textCase(.uppercase)
                .foregroundStyle(Design.muted)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .frame(height: 40)
        .background(Design.card, in: Capsule())
        .overlay(Capsule().stroke(Design.stroke))
    }
}

private struct HorizontalPresetStrip: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(model.allPresets) { preset in
                    Button {
                        model.selectPreset(preset)
                    } label: {
                        HStack(spacing: 8) {
                            Circle()
                                .fill(preset.accent)
                                .frame(width: 8, height: 8)
                            Text(preset.shortName)
                                .font(.system(size: 12, weight: .bold))
                                .lineLimit(1)
                        }
                        .foregroundStyle(Design.ink)
                        .padding(.horizontal, 12)
                        .frame(height: 34)
                        .background(
                            preset.id == model.activePreset.id ? Design.card : Design.ink.opacity(0.05),
                            in: Capsule()
                        )
                        .overlay(Capsule().stroke(preset.id == model.activePreset.id ? preset.accent.opacity(0.42) : .clear))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

private struct TimerPanel: View {
    @EnvironmentObject private var model: EyeTimerModel
    let layout: LayoutMode

    private var timerFontSize: CGFloat {
        switch layout {
        case .full: 86
        case .compact: 72
        case .narrow: 56
        }
    }

    var body: some View {
        if layout == .narrow {
            NarrowTimerPanel()
        } else {
            CircularTimerPanel(layout: layout)
        }
    }
}

private struct CircularTimerPanel: View {
    @EnvironmentObject private var model: EyeTimerModel
    let layout: LayoutMode

    private var timerFontSize: CGFloat {
        layout == .full ? 86 : 72
    }

    var body: some View {
        VStack(spacing: layout == .full ? 18 : 12) {
            Spacer(minLength: 0)

            ZStack {
                Circle()
                    .stroke(Design.ink.opacity(0.08), lineWidth: layout == .narrow ? 8 : 10)

                Circle()
                    .trim(from: 0, to: max(0, min(1, model.progress)))
                    .stroke(
                        model.activePreset.accent,
                        style: StrokeStyle(lineWidth: layout == .narrow ? 8 : 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: model.activePreset.accent.opacity(0.22), radius: 12, y: 8)
                    .animation(.smooth(duration: 0.45), value: model.progress)

                VStack(spacing: layout == .narrow ? 8 : 10) {
                    Text(model.mode == .resting ? "Break" : "Focus")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Design.muted)
                        .textCase(.uppercase)

                    Text(formattedTime(model.displayRemaining))
                        .font(.system(size: timerFontSize, weight: .bold, design: .rounded))
                        .foregroundStyle(Design.ink)
                        .monospacedDigit()
                        .minimumScaleFactor(0.58)

                    Text(model.mode == .resting ? model.activePreset.distanceCue : model.activePreset.note)
                        .font(.system(size: layout == .narrow ? 13 : 14))
                        .foregroundStyle(Design.muted)
                        .multilineTextAlignment(.center)
                        .lineLimit(layout == .narrow ? 2 : 3)
                        .frame(maxWidth: layout == .narrow ? 220 : 280)
                }
                .padding(layout == .narrow ? 24 : 34)
            }
            .frame(maxWidth: layout == .full ? 430 : 330, maxHeight: layout == .full ? 430 : 330)
            .aspectRatio(1, contentMode: .fit)

            HStack(spacing: 10) {
                Button {
                    if model.mode == .running || model.mode == .resting {
                        model.pause()
                    } else {
                        model.start()
                    }
                } label: {
                    Label(model.mode == .running || model.mode == .resting ? "Pause" : "Start",
                          systemImage: model.mode == .running || model.mode == .resting ? "pause.fill" : "play.fill")
                }
                .primaryActionStyle(accent: model.activePreset.accent)

                Button {
                    model.reset()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 42, height: 42)
                }
                .iconActionStyle()
                .help("Reset timer")
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .panelStyle()
    }
}

private struct NarrowTimerPanel: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        VStack(spacing: 18) {
            HStack(alignment: .firstTextBaseline) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(model.mode == .resting ? "Break" : "Focus")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Design.muted)
                        .textCase(.uppercase)

                    Text(formattedTime(model.displayRemaining))
                        .font(.system(size: 64, weight: .bold, design: .rounded))
                        .foregroundStyle(Design.ink)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }

                Spacer(minLength: 18)

                Text(model.mode == .resting ? model.activePreset.distanceCue : model.activePreset.note)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Design.bodyText)
                    .lineSpacing(3)
                    .lineLimit(3)
                    .frame(maxWidth: 260, alignment: .leading)
            }

            GeometryReader { proxy in
                Capsule()
                    .fill(Design.ink.opacity(0.08))
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(model.activePreset.accent)
                            .frame(width: max(8, proxy.size.width * max(0, min(1, model.progress))))
                            .animation(.smooth(duration: 0.45), value: model.progress)
                    }
            }
            .frame(height: 8)

            HStack(spacing: 10) {
                Button {
                    if model.mode == .running || model.mode == .resting {
                        model.pause()
                    } else {
                        model.start()
                    }
                } label: {
                    Label(model.mode == .running || model.mode == .resting ? "Pause" : "Start",
                          systemImage: model.mode == .running || model.mode == .resting ? "pause.fill" : "play.fill")
                }
                .primaryActionStyle(accent: model.activePreset.accent)

                Button {
                    model.reset()
                } label: {
                    Image(systemName: "arrow.clockwise")
                        .frame(width: 42, height: 42)
                }
                .iconActionStyle()
                .help("Reset timer")

                Spacer()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .panelStyle()
    }
}

private struct SettingsColumn: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 12) {
                Label("Appearance", systemImage: "circle.lefthalf.filled")
                    .panelTitleStyle()

                Picker("Appearance", selection: $model.appearance) {
                    ForEach(AppAppearance.allCases) { appearance in
                        Text(appearance.label).tag(appearance)
                    }
                }
                .pickerStyle(.segmented)
                .labelsHidden()
            }
            .panelStyle()

            VStack(alignment: .leading, spacing: 14) {
                Label("Custom timer", systemImage: "slider.horizontal.3")
                    .panelTitleStyle()

                TextField("Name", text: $model.customName)
                    .onChange(of: model.customName) { _, _ in model.useCustom() }
                    .textFieldStyle(.roundedBorder)

                HStack(spacing: 10) {
                    NumericField(title: "Work min", value: $model.customFocusMinutes, range: 1...180)
                    NumericField(title: "Break sec", value: $model.customBreakSeconds, range: 5...600)
                }
            }
            .panelStyle()

            VStack(alignment: .leading, spacing: 14) {
                Label("Reminder style", systemImage: "headphones")
                    .panelTitleStyle()

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(ReminderSound.allCases) { sound in
                        Button {
                            model.sound = sound
                            if let id = sound.systemSoundIDs.first {
                                NSSound(named: id)?.play()
                            }
                        } label: {
                            Label(sound.label, systemImage: sound == .off ? "speaker.slash.fill" : "speaker.wave.2.fill")
                                .lineLimit(1)
                                .minimumScaleFactor(0.82)
                                .frame(maxWidth: .infinity, minHeight: 40)
                        }
                        .compactChoiceStyle(isSelected: model.sound == sound, accent: model.activePreset.accent)
                    }
                }

                AlignedToggleRow(
                    title: "Native notification",
                    systemImage: model.nativeNotifications ? "bell.fill" : "bell.slash.fill",
                    isOn: $model.nativeNotifications
                )

                AlignedToggleRow(
                    title: "Visual reminder",
                    systemImage: "eye.fill",
                    isOn: $model.visualReminders
                )
            }
            .panelStyle()
        }
    }
}

private struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Settings")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundStyle(Design.ink)
                    Text("Tune the rhythm without crowding the timer.")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(Design.muted)
                }

                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 34, height: 34)
                }
                .iconActionStyle()
            }

            SettingsColumn()
        }
        .padding(22)
        .frame(width: 420)
        .background(Design.canvas)
        .foregroundStyle(Design.ink)
    }
}

private struct NumericField: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(Design.muted)

            TextField(title, value: $value, format: .number)
                .textFieldStyle(.roundedBorder)
                .foregroundStyle(Design.ink)
                .monospacedDigit()
                .onSubmit { clampAndUseCustom() }
                .onChange(of: value) { _, _ in clampAndUseCustom() }
        }
    }

    private func clampAndUseCustom() {
        let clamped = min(max(value, range.lowerBound), range.upperBound)
        if clamped != value {
            value = clamped
        }
        model.useCustom()
    }
}

private struct AlignedToggleRow: View {
    let title: String
    let systemImage: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: systemImage)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Design.bodyText)
                .frame(width: 22)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Design.bodyText)

            Spacer(minLength: 16)

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .toggleStyle(.switch)
                .frame(width: 54, alignment: .trailing)
        }
        .frame(minHeight: 34)
    }
}

private struct BottomStrip: View {
    let layout: LayoutMode
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        if layout == .narrow {
            VStack(alignment: .leading, spacing: 10) {
                StatBlock(title: "Breaks completed", value: "\(model.completedBreaks)")
                StatBlock(title: "Next cue", value: model.activePreset.distanceCue)
                StatBlock(title: "Last action", value: model.lastAction)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .panelStyle()
        } else {
            HStack(spacing: 22) {
                StatBlock(title: "Breaks completed", value: "\(model.completedBreaks)")
                    .frame(width: layout == .full ? 150 : 132, alignment: .leading)
                StatBlock(title: "Next cue", value: model.activePreset.distanceCue)
                    .frame(width: layout == .full ? 190 : 156, alignment: .leading)
                StatBlock(title: "Last action", value: model.lastAction)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .panelStyle()
        }
    }
}

private struct StatBlock: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Design.muted)
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(Design.ink)
                .lineLimit(1)
                .truncationMode(.tail)
        }
    }
}

private struct ReminderOverlay: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.black.opacity(0.26))
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Image(systemName: "cup.and.saucer.fill")
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundStyle(Design.ink)
                    .frame(width: 48, height: 48)
                    .background(model.activePreset.accent.opacity(0.28), in: RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 8) {
                    Text("Timer complete")
                        .eyebrowStyle()
                    Text(model.activePreset.reminderTitle)
                        .font(.system(size: 34, weight: .bold))
                        .foregroundStyle(Design.ink)
                    Text(model.activePreset.reminderBody)
                        .font(.system(size: 15))
                        .foregroundStyle(Design.bodyText)
                        .lineSpacing(4)
                }

                Text(reminderQuotes[model.quoteIndex])
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(Design.ink)
                    .lineSpacing(4)
                    .padding(.leading, 16)
                    .overlay(alignment: .leading) {
                        Rectangle()
                            .fill(model.activePreset.accent)
                            .frame(width: 3)
                    }

                HStack(spacing: 10) {
                    Button {
                        model.acceptBreak()
                    } label: {
                        Label("Start \(model.activePreset.breakSeconds)s", systemImage: "checkmark")
                    }
                    .primaryActionStyle(accent: model.activePreset.accent)

                    Button {
                        model.skipBreak()
                    } label: {
                        Label("Restart timer", systemImage: "timer")
                    }
                    .secondaryActionStyle()

                    Button {
                        model.disableForNow()
                    } label: {
                        Image(systemName: "xmark")
                            .frame(width: 42, height: 42)
                    }
                    .iconActionStyle()
                    .help("Disable reminders for now")
                }
            }
            .frame(width: 500, alignment: .leading)
            .padding(28)
            .background(Design.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Design.stroke))
            .shadow(color: .black.opacity(0.22), radius: 44, y: 22)
            .padding(24)
        }
    }
}

private struct BreakBanner: View {
    @EnvironmentObject private var model: EyeTimerModel

    var body: some View {
        VStack {
            Spacer()
            HStack(spacing: 14) {
                Text("Look at \(model.activePreset.distanceCue)")
                Text(formattedTime(model.breakRemaining))
                    .fontWeight(.bold)
                    .monospacedDigit()
                    .foregroundStyle(model.activePreset.accent)
            }
            .font(.system(size: 14, weight: .semibold))
            .padding(.horizontal, 18)
            .frame(height: 50)
            .background(.black.opacity(0.78), in: Capsule())
            .foregroundStyle(.white)
            .shadow(color: .black.opacity(0.24), radius: 22, y: 14)
            .padding(.bottom, 26)
        }
        .allowsHitTesting(false)
    }
}
