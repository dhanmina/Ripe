import SwiftUI

@main
struct RipeApp: App {
    @StateObject private var engine = PomodoroEngine()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(engine: engine)
        } label: {
            Label(menuBarTitle, systemImage: menuBarSymbol)
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        let total = max(0, Int(engine.remaining.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    private var menuBarSymbol: String {
        switch engine.phase {
        case .work: return "leaf.fill"
        case .shortBreak, .longBreak: return "cup.and.saucer.fill"
        }
    }
}
