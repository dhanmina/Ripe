import AppKit
import Foundation

/// Watches for system sleep and screen lock — the two unambiguous "stepped
/// away from the Mac" signals — and calls back so the timer can auto-pause.
/// Deliberately does not attempt keyboard/mouse-idle detection: no-input time
/// is not a reliable "away" signal for a focus timer (reading, watching a
/// video, or thinking through a problem all look identical to idle).
final class IdleObserver: NSObject {
    private let onIdle: () -> Void

    init(onIdle: @escaping () -> Void) {
        self.onIdle = onIdle
        super.init()
        let workspaceCenter = NSWorkspace.shared.notificationCenter
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleIdleEvent),
            name: NSWorkspace.willSleepNotification,
            object: nil
        )
        workspaceCenter.addObserver(
            self,
            selector: #selector(handleIdleEvent),
            name: NSWorkspace.screensDidSleepNotification,
            object: nil
        )
        DistributedNotificationCenter.default().addObserver(
            self,
            selector: #selector(handleIdleEvent),
            name: Notification.Name("com.apple.screenIsLocked"),
            object: nil
        )
    }

    @objc private func handleIdleEvent() {
        onIdle()
    }

    deinit {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        DistributedNotificationCenter.default().removeObserver(self)
    }
}
