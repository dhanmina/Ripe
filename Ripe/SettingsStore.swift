import Combine
import Foundation

final class SettingsStore: ObservableObject {
    private enum Keys {
        static let workMinutes = "com.ripe.settings.workMinutes"
        static let shortBreakMinutes = "com.ripe.settings.shortBreakMinutes"
        static let longBreakMinutes = "com.ripe.settings.longBreakMinutes"
        static let sessionsBeforeLongBreak = "com.ripe.settings.sessionsBeforeLongBreak"
        static let soundName = "com.ripe.settings.soundName"
    }

    private let userDefaults: UserDefaults

    @Published var workMinutes: Int {
        didSet { userDefaults.set(workMinutes, forKey: Keys.workMinutes) }
    }
    @Published var shortBreakMinutes: Int {
        didSet { userDefaults.set(shortBreakMinutes, forKey: Keys.shortBreakMinutes) }
    }
    @Published var longBreakMinutes: Int {
        didSet { userDefaults.set(longBreakMinutes, forKey: Keys.longBreakMinutes) }
    }
    @Published var sessionsBeforeLongBreak: Int {
        didSet { userDefaults.set(sessionsBeforeLongBreak, forKey: Keys.sessionsBeforeLongBreak) }
    }
    @Published var soundName: String {
        didSet { userDefaults.set(soundName, forKey: Keys.soundName) }
    }

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        workMinutes = userDefaults.object(forKey: Keys.workMinutes) as? Int ?? 25
        shortBreakMinutes = userDefaults.object(forKey: Keys.shortBreakMinutes) as? Int ?? 5
        longBreakMinutes = userDefaults.object(forKey: Keys.longBreakMinutes) as? Int ?? 15
        sessionsBeforeLongBreak = userDefaults.object(forKey: Keys.sessionsBeforeLongBreak) as? Int ?? 4
        soundName = userDefaults.string(forKey: Keys.soundName) ?? NotificationSoundOption.system.rawValue
    }

    func duration(for phase: PomodoroPhase) -> TimeInterval {
        switch phase {
        case .work: return TimeInterval(workMinutes * 60)
        case .shortBreak: return TimeInterval(shortBreakMinutes * 60)
        case .longBreak: return TimeInterval(longBreakMinutes * 60)
        }
    }
}
