import SwiftUI

struct ReminderPanelView: View {
    @ObservedObject var model: EyeTimerModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(model.activePreset.accent.opacity(0.24))
                    Image(systemName: "eye.trianglebadge.exclamationmark")
                        .font(.system(size: 27, weight: .semibold))
                        .foregroundStyle(Design.ink)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 6) {
                    Text("Eye break now")
                        .font(.system(size: 12, weight: .heavy))
                        .foregroundStyle(Design.muted)
                        .textCase(.uppercase)

                    Text(model.activePreset.reminderTitle)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(Design.ink)
                        .lineLimit(2)

                    Text(model.activePreset.reminderBody)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(Design.bodyText)
                        .lineSpacing(3)
                        .lineLimit(2)
                }
            }

            Text(reminderQuotes[model.quoteIndex])
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(Design.ink)
                .lineSpacing(3)
                .padding(.leading, 14)
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
                    Label("Restart", systemImage: "timer")
                }
                .secondaryActionStyle()

                Button {
                    model.disableForNow()
                } label: {
                    Label("Disable", systemImage: "bell.slash")
                }
                .secondaryActionStyle()
            }
        }
        .padding(26)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .background(.white.opacity(0.96), in: RoundedRectangle(cornerRadius: 14))
        .overlay(RoundedRectangle(cornerRadius: 14).stroke(model.activePreset.accent.opacity(0.42), lineWidth: 1.5))
        .shadow(color: .black.opacity(0.28), radius: 46, y: 22)
    }
}
