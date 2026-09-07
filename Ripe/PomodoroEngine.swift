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
    @Published private(set) var remaining: TimeInterval = PomodoroPhase.work.duration
    @Published private(set) var sessionsCompleted: Int = 0
    @Published private(set) var statsToday: Int
    @Published private(set) var statsLast7Days: [(date: Date, count: Int)]

    private var endDate: Date?
    private var timer: Timer?
    private let statsStore: StatsStore
    private let notificationManager: NotificationManager

    init(statsStore: StatsStore = StatsStore(), notificationManager: NotificationManager = NotificationManager()) {
        self.statsStore = statsStore
        self.notificationManager = notificationManager
        self.statsToday = statsStore.today
        self.statsLast7Days = statsStore.last7Days
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
        remaining = phase.duration
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
            self.endDate = Date().addingTimeInterval(remaining)
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
            phase = sessionsCompleted % 4 == 0 ? .longBreak : .shortBreak
        } else {
            phase = .work
        }
        remaining = phase.duration
        notificationManager.notifyPhaseEnded(finishedPhase: finishedPhase, nextPhase: phase)
    }
}
