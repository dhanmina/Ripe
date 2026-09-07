import AppKit
import Combine
import Foundation
import UserNotifications

enum NotificationSoundOption: String, CaseIterable, Identifiable {
    case system = "Default"
    case ping = "Ping"
    case glass = "Glass"
    case hero = "Hero"
    case pop = "Pop"
    case purr = "Purr"

    var id: String { rawValue }

    func play() {
        if self == .system {
            NSSound.beep()
        } else if let sound = NSSound(named: NSSound.Name(rawValue)) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}

enum NotificationAuthorizationState {
    case unknown
    case authorized
    case denied
}

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published private(set) var authorizationState: NotificationAuthorizationState = .unknown

    private let settingsStore: SettingsStore

    init(settingsStore: SettingsStore = SettingsStore()) {
        self.settingsStore = settingsStore
        super.init()
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { [weak self] granted, _ in
            DispatchQueue.main.async {
                self?.authorizationState = granted ? .authorized : .denied
            }
        }
    }

    func refreshAuthorizationState() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationState = settings.authorizationStatus == .authorized ? .authorized : .denied
            }
        }
    }

    func openSystemSettings() {
        guard let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") else { return }
        NSWorkspace.shared.open(url)
    }

    func notifyPhaseEnded(finishedPhase: PomodoroPhase, nextPhase: PomodoroPhase) {
        let content = UNMutableNotificationContent()
        content.title = "\(finishedPhase.label) complete"
        content.body = "Starting \(nextPhase.label.lowercased())."
        // Sound is played separately via NSSound below: UNNotificationSound(named:)
        // only resolves sound files bundled inside the app, not the classic
        // /System/Library/Sounds set this picker offers.

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request)

        let option = NotificationSoundOption(rawValue: settingsStore.soundName) ?? .system
        option.play()
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner])
    }
}
