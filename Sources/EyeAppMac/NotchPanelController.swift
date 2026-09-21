import AppKit
import Combine
import SwiftUI

@MainActor
final class NotchGeometry: ObservableObject {
    @Published var panelWidth: CGFloat = 460
    @Published var notchGap: CGFloat = 0
}

@MainActor
final class NotchPanelController {
    private let panel: NSPanel
    private let geometry = NotchGeometry()
    private var poller: Timer?
    private weak var model: EyeTimerModel?

    private let panelHeight: CGFloat = 84
    private let triggerWidth: CGFloat = 420
    private let triggerHeight: CGFloat = 32
    private let minimumWingWidth: CGFloat = 204
    private let horizontalInset: CGFloat = 14

    init(model: EyeTimerModel) {
        self.model = model
        panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: NSSize(width: geometry.panelWidth, height: panelHeight)),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.contentView = NSHostingView(rootView: NotchPanelView(model: model, geometry: geometry))
        panel.orderOut(nil)

        startPolling()
    }

    private func startPolling() {
        poller = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateVisibility()
            }
        }
    }

    private func updateVisibility() {
        let mouse = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main

        guard let screen else {
            panel.orderOut(nil)
            return
        }

        updateGeometry(for: screen)
        let targetFrame = panelFrame(for: screen)
        if panel.frame.origin != targetFrame.origin {
            panel.setFrame(targetFrame, display: false)
        } else if panel.frame.size != targetFrame.size {
            panel.setFrame(targetFrame, display: true)
        }

        let centerX = screen.frame.midX
        let topY = screen.frame.maxY
        let nearTopCenter =
            abs(mouse.x - centerX) <= triggerWidth / 2 &&
            mouse.y >= topY - triggerHeight &&
            mouse.y <= topY
        let insidePanel =
            panel.isVisible &&
            targetFrame.insetBy(dx: -6, dy: -14).contains(mouse)

        if nearTopCenter || insidePanel {
            panel.orderFrontRegardless()
        } else {
            panel.orderOut(nil)
        }
    }

    private func panelFrame(for screen: NSScreen) -> NSRect {
        NSRect(
            x: screen.frame.midX - geometry.panelWidth / 2,
            y: screen.frame.maxY - panelHeight,
            width: geometry.panelWidth,
            height: panelHeight
        )
    }

    private func updateGeometry(for screen: NSScreen) {
        let notchGap = measuredNotchGap(for: screen)
        let targetWidth = min(
            screen.frame.width - 24,
            max(430, notchGap + minimumWingWidth * 2 + horizontalInset * 2)
        )

        if abs(geometry.notchGap - notchGap) > 0.5 {
            geometry.notchGap = notchGap
        }

        if abs(geometry.panelWidth - targetWidth) > 0.5 {
            geometry.panelWidth = targetWidth
        }
    }

    private func measuredNotchGap(for screen: NSScreen) -> CGFloat {
        guard
            let left = screen.auxiliaryTopLeftArea,
            let right = screen.auxiliaryTopRightArea,
            !left.isEmpty,
            !right.isEmpty
        else {
            return 0
        }

        return max(0, right.minX - left.maxX)
    }
}
