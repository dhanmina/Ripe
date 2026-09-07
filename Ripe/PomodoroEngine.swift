import Foundation
import Combine

enum PomodoroRunState {
    case idle
    case running
    case paused
}

final class PomodoroEngine: ObservableObject {
    @Published private(set) var phase: PomodoroPhase = .work
    @Published private(set) var runState: PomodoroRunState = .idle
    @Published private(set) var remaining: TimeInterval
    @Published private(set) var phaseDuration: TimeInterval
    @Published private(set) var sessionsCompleted: Int = 0
    @Published private(set) var statsToday: Int
    @Published private(set) var statsLast7Days: [(date: Date, count: Int)]
    @Published private(set) var statsAllTime: Int

    private var endDate: Date?
    private var timer: Timer?
    private var settingsCancellable: AnyCancellable?
    private var idleObserver: IdleObserver?
    private let statsStore: StatsStore
    private let notificationManager: NotificationManager
    private let settingsStore: SettingsStore

    init(
        statsStore: StatsStore = StatsStore(),
        notificationManager: NotificationManager? = nil,
        settingsStore: SettingsStore = SettingsStore()
    ) {
        self.statsStore = statsStore
        self.settingsStore = settingsStore
        self.notificationManager = notificationManager ?? NotificationManager(settingsStore: settingsStore)
        self.statsToday = statsStore.today
        self.statsLast7Days = statsStore.last7Days
        self.statsAllTime = statsStore.allTime
        self.phaseDuration = settingsStore.duration(for: .work)
        self.remaining = settingsStore.duration(for: .work)

        settingsCancellable = settingsStore.objectWillChange.sink { [weak self] _ in
            // objectWillChange fires before the new value lands, so read it
            // on the next runloop tick once the change has actually applied.
            DispatchQueue.main.async {
                self?.syncDurationIfIdle()
            }
        }

        idleObserver = IdleObserver { [weak self] in
            self?.pause()
        }
    }

    private func syncDurationIfIdle() {
        guard runState == .idle else { return }
        phaseDuration = settingsStore.duration(for: phase)
        remaining = phaseDuration
    }

    func start() {
        guard runState != .running else { return }
        endDate = Date().addingTimeInterval(remaining)
        runState = .running
        if timer == nil {
            let newTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.tick()
            }
            RunLoop.main.add(newTimer, forMode: .common)
            timer = newTimer
        }
    }

    func pause() {
        guard runState == .running else { return }
        runState = .paused
        timer?.invalidate()
        timer = nil
    }

    func reset() {
        timer?.invalidate()
        timer = nil
        phase = .work
        runState = .idle
        phaseDuration = settingsStore.duration(for: phase)
        remaining = phaseDuration
        endDate = nil
    }

    func skip() {
        guard runState != .idle else { return }
        completeCurrentPhase()
        if runState == .running {
            endDate = Date().addingTimeInterval(remaining)
        }
    }

    private func tick() {
        guard let endDate else { return }
        let secondsLeft = endDate.timeIntervalSinceNow
        if secondsLeft <= 0 {
            completeCurrentPhase()
            timer?.invalidate()
            timer = nil
            runState = .idle
            self.endDate = nil
        } else {
            remaining = secondsLeft
        }
    }

    private func completeCurrentPhase() {
        let finishedPhase = phase
        if finishedPhase == .work {
            statsStore.recordCompletion()
            sessionsCompleted += 1
            statsToday = statsStore.today
            statsLast7Days = statsStore.last7Days
            statsAllTime = statsStore.allTime
            phase = sessionsCompleted % settingsStore.sessionsBeforeLongBreak == 0 ? .longBreak : .shortBreak
        } else {
            phase = .work
        }
        phaseDuration = settingsStore.duration(for: phase)
        remaining = phaseDuration
        notificationManager.notifyPhaseEnded(finishedPhase: finishedPhase, nextPhase: phase)
    }
}
