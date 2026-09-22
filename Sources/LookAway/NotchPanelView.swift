import SwiftUI

struct NotchPanelView: View {
    @ObservedObject var model: EyeTimerModel
    @ObservedObject var geometry: NotchGeometry
    private let height: CGFloat = 78
    private let horizontalInset: CGFloat = 10

    var body: some View {
        ZStack(alignment: .bottom) {
            UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                .fill(notchBackground)
                .overlay(
                    UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20)
                        .stroke(notchMuted.opacity(0.12))
                )
                .shadow(color: .black.opacity(model.appearance == .dark ? 0.28 : 0.16), radius: 16, y: 9)

            HStack(spacing: 0) {
                leftInfo
                    .frame(width: wingWidth, alignment: .leading)

                Color.clear
                    .frame(width: geometry.notchGap)
                    .accessibilityHidden(true)

                rightInfo
                    .frame(width: wingWidth, alignment: .trailing)
            }
            .padding(.horizontal, horizontalInset)
            .padding(.top, 9)
            .padding(.bottom, 20)

            sharedProgressBar
                .padding(.horizontal, 12)
                .padding(.bottom, 9)
        }
        .frame(width: geometry.panelWidth, height: height)
        .contentShape(UnevenRoundedRectangle(bottomLeadingRadius: 20, bottomTrailingRadius: 20))
        .onTapGesture {
            NSApp.activate(ignoringOtherApps: true)
        }
        .preferredColorScheme(model.appearance.colorScheme)
    }

    private var wingWidth: CGFloat {
        max(0, (geometry.panelWidth - geometry.notchGap - horizontalInset * 2) / 2)
    }

    private var leftInfo: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(notchMuted.opacity(0.28), lineWidth: 2.5)
                Circle()
                    .trim(from: 0, to: max(0.02, min(1, model.progress)))
                    .stroke(model.activePreset.accent, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
            }
            .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 5) {
                    Circle()
                        .fill(statusColor)
                        .frame(width: 5, height: 5)
                    Text(statusTitle)
                        .font(.system(size: 9, weight: .heavy))
                        .foregroundStyle(notchMuted)
                        .textCase(.uppercase)
                }

                Text(model.mode == .resting ? model.activePreset.distanceCue : model.activePreset.name)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(notchInk)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
        }
    }

    private var rightInfo: some View {
        HStack(spacing: 8) {
            VStack(alignment: .trailing, spacing: 1) {
                Text(formattedTime(model.displayRemaining))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(notchInk)
                    .monospacedDigit()
                    .lineLimit(1)
                Text(model.mode == .prompt ? "choose an option" : nextCue)
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(notchMuted)
                    .lineLimit(1)
            }

            actionButton
        }
    }

    private var sharedProgressBar: some View {
        GeometryReader { proxy in
            Capsule()
                .fill(notchMuted.opacity(0.18))
                .overlay(alignment: .leading) {
                    Capsule()
                        .fill(model.activePreset.accent)
                        .frame(width: max(4, proxy.size.width * max(0, min(1, model.progress))))
                        .animation(.smooth(duration: 0.45), value: model.progress)
                }
        }
        .frame(height: 4)
    }

    private var statusTitle: String {
        switch model.mode {
        case .idle: "Ready"
        case .running: "Focus"
        case .paused: "Paused"
        case .prompt: "Break due"
        case .resting: "Resting"
        }
    }

    private var statusColor: Color {
        switch model.mode {
        case .running, .resting: model.activePreset.accent
        case .prompt: .orange
        case .paused: .yellow
        case .idle: .white.opacity(0.45)
        }
    }

    private var nextCue: String {
        model.mode == .resting ? "until focus" : "to break"
    }

    @ViewBuilder
    private var actionButton: some View {
        Button {
            if model.mode == .prompt {
                model.acceptBreak()
            } else {
                model.toggle()
            }
        } label: {
            Image(systemName: actionIcon)
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(notchInk)
                .frame(width: 24, height: 22)
        }
        .buttonStyle(.plain)
        .background(actionBackground, in: Capsule())
    }

    private var actionIcon: String {
        switch model.mode {
        case .running, .resting: "pause.fill"
        case .prompt: "checkmark"
        case .idle, .paused: "play.fill"
        }
    }

    private var actionBackground: Color {
        model.mode == .prompt ? model.activePreset.accent.opacity(0.86) : notchMuted.opacity(0.16)
    }

    private var notchBackground: Color {
        model.appearance == .dark ? .black.opacity(0.88) : .white.opacity(0.92)
    }

    private var notchInk: Color {
        model.appearance == .dark ? .white : Design.ink
    }

    private var notchMuted: Color {
        model.appearance == .dark ? .white.opacity(0.58) : Design.muted
    }
}
