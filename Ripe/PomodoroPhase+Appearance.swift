import SwiftUI

extension PomodoroPhase {
    var symbolName: String {
        switch self {
        case .work: return "timer"
        case .shortBreak: return "cup.and.saucer.fill"
        case .longBreak: return "moon.zzz.fill"
        }
    }

    var tint: Color {
        switch self {
        case .work: return .orange
        case .shortBreak: return .mint
        case .longBreak: return .indigo
        }
    }
}
