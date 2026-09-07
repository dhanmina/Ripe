import Foundation
import UserNotifications

final class NotificationManager {
    init() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func notifyPhaseEnded(finishedPhase: PomodoroPhase, nextPhase: PomodoroPhase) {
        let content = UNMutableNotificationContent()
        content.title = "\(finishedPhase.label) complete"
        content.body = "Starting \(nextPhase.label.lowercased())."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)
    }
}
