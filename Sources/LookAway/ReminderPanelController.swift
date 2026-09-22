import AppKit
import Combine
import SwiftUI

@MainActor
final class ReminderPanelController {
    private let panel: NSPanel
    private weak var model: EyeTimerModel?
    private var cancellables = Set<AnyCancellable>()

    init(model: EyeTimerModel) {
        self.model = model

        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 520, height: 330),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.hidesOnDeactivate = false
        panel.level = .screenSaver
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .transient]
        panel.contentView = NSHostingView(
            rootView: ReminderPanelView(model: model)
                .preferredColorScheme(model.appearance.colorScheme)
        )
        panel.orderOut(nil)

        model.$mode
            .combineLatest(model.$visualReminders)
            .receive(on: RunLoop.main)
            .sink { [weak self] mode, visualReminders in
                guard let self else { return }
                if mode == .prompt && visualReminders {
                    self.show()
                } else {
                    self.panel.orderOut(nil)
                }
            }
            .store(in: &cancellables)
    }

    private func show() {
        guard let screen = activeScreen() else { return }

        let width = min(520, screen.visibleFrame.width - 48)
        let height: CGFloat = 330
        let frame = NSRect(
            x: screen.visibleFrame.midX - width / 2,
            y: screen.visibleFrame.midY - height / 2,
            width: width,
            height: height
        )

        panel.setFrame(frame, display: true)
        panel.orderFrontRegardless()
    }

    private func activeScreen() -> NSScreen? {
        let mouse = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouse) } ?? NSScreen.main
    }
}
