import AppKit
import SwiftUI

enum Design {
    static let ink = adaptive(
        light: NSColor(red: 0.10, green: 0.10, blue: 0.09, alpha: 1),
        dark: NSColor(red: 0.93, green: 0.94, blue: 0.91, alpha: 1)
    )
    static let bodyText = adaptive(
        light: NSColor(red: 0.27, green: 0.26, blue: 0.23, alpha: 1),
        dark: NSColor(red: 0.76, green: 0.75, blue: 0.69, alpha: 1)
    )
    static let muted = adaptive(
        light: NSColor(red: 0.48, green: 0.46, blue: 0.40, alpha: 1),
        dark: NSColor(red: 0.62, green: 0.62, blue: 0.56, alpha: 1)
    )
    static let stroke = adaptive(
        light: NSColor.black.withAlphaComponent(0.10),
        dark: NSColor.white.withAlphaComponent(0.12)
    )
    static let card = adaptive(
        light: NSColor.white.withAlphaComponent(0.92),
        dark: NSColor(red: 0.12, green: 0.12, blue: 0.11, alpha: 0.94)
    )
    static let sidebar = adaptive(
        light: NSColor.white.withAlphaComponent(0.64),
        dark: NSColor(red: 0.08, green: 0.08, blue: 0.075, alpha: 0.72)
    )
    static let canvas = adaptive(
        light: NSColor(red: 0.97, green: 0.96, blue: 0.93, alpha: 1),
        dark: NSColor(red: 0.08, green: 0.08, blue: 0.075, alpha: 1)
    )
    static let canvasWarm = adaptive(
        light: NSColor(red: 0.99, green: 0.97, blue: 0.92, alpha: 1),
        dark: NSColor(red: 0.10, green: 0.095, blue: 0.085, alpha: 1)
    )
    static let canvasCool = adaptive(
        light: NSColor(red: 0.90, green: 0.96, blue: 0.94, alpha: 1),
        dark: NSColor(red: 0.06, green: 0.12, blue: 0.12, alpha: 1)
    )

    private static func adaptive(light: NSColor, dark: NSColor) -> Color {
        Color(nsColor: NSColor(name: nil) { appearance in
            let match = appearance.bestMatch(from: [.darkAqua, .aqua])
            return match == .darkAqua ? dark : light
        })
    }
}

extension View {
    func panelStyle() -> some View {
        padding(16)
            .background(Design.card, in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Design.stroke))
            .shadow(color: .black.opacity(0.07), radius: 24, y: 12)
    }

    func eyebrowStyle() -> some View {
        font(.system(size: 11, weight: .heavy))
            .foregroundStyle(Design.muted)
            .textCase(.uppercase)
    }

    func panelTitleStyle() -> some View {
        font(.system(size: 13, weight: .bold))
            .foregroundStyle(Design.muted)
    }

    func primaryActionStyle(accent: Color) -> some View {
        buttonStyle(PrimaryActionButtonStyle(accent: accent))
    }

    func secondaryActionStyle() -> some View {
        buttonStyle(SecondaryActionButtonStyle())
    }

    func iconActionStyle() -> some View {
        buttonStyle(IconActionButtonStyle())
    }

    func compactChoiceStyle(isSelected: Bool, accent: Color) -> some View {
        buttonStyle(CompactChoiceButtonStyle(isSelected: isSelected, accent: accent))
    }
}

private struct PrimaryActionButtonStyle: ButtonStyle {
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Design.ink)
            .padding(.horizontal, 18)
            .frame(minWidth: 126, minHeight: 42)
            .background(accent, in: RoundedRectangle(cornerRadius: 8))
            .shadow(color: accent.opacity(configuration.isPressed ? 0.18 : 0.34), radius: 18, y: 10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Design.ink)
            .padding(.horizontal, 16)
            .frame(minHeight: 42)
            .background(Design.card.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Design.stroke))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct IconActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 14, weight: .bold))
            .foregroundStyle(Design.ink)
            .background(Design.card.opacity(configuration.isPressed ? 0.78 : 1), in: RoundedRectangle(cornerRadius: 8))
            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Design.stroke))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

private struct CompactChoiceButtonStyle: ButtonStyle {
    let isSelected: Bool
    let accent: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(Design.ink.opacity(0.86))
            .background(
                isSelected ? accent.opacity(configuration.isPressed ? 0.26 : 0.34) : Design.ink.opacity(configuration.isPressed ? 0.08 : 0.05),
                in: RoundedRectangle(cornerRadius: 8)
            )
    }
}
