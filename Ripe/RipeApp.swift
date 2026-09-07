import SwiftUI

@main
struct RipeApp: App {
    @StateObject private var engine = PomodoroEngine()
    @StateObject private var loginItemManager = LoginItemManager()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(engine: engine)
        } label: {
            Label {
                Text(menuBarTitle)
                    .monospacedDigit()
            } icon: {
                Image(systemName: engine.phase.symbolName)
            }
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView(loginItemManager: loginItemManager)
        }
    }

    private var menuBarTitle: String {
        let total = max(0, Int(engine.remaining.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
