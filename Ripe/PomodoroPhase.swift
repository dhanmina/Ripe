import Foundation

enum PomodoroPhase: String {
    case work
    case shortBreak
    case longBreak

    var label: String {
        switch self {
        case .work: return "Focus"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
}
