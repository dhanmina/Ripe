import SwiftUI

@main
struct RipeApp: App {
    @StateObject private var settingsStore: SettingsStore
    @StateObject private var notificationManager: NotificationManager
    @StateObject private var engine: PomodoroEngine

    init() {
        let settingsStore = SettingsStore()
        let notificationManager = NotificationManager(settingsStore: settingsStore)
        _settingsStore = StateObject(wrappedValue: settingsStore)
        _notificationManager = StateObject(wrappedValue: notificationManager)
        _engine = StateObject(wrappedValue: PomodoroEngine(
            notificationManager: notificationManager,
            settingsStore: settingsStore
        ))
    }

    var body: some Scene {
        MenuBarExtra {
            MenuBarView(engine: engine, settingsStore: settingsStore, notificationManager: notificationManager)
        } label: {
            Label {
                Text(menuBarTitle)
                    .monospacedDigit()
            } icon: {
                Image(systemName: engine.phase.symbolName)
            }
        }
        .menuBarExtraStyle(.window)
    }

    private var menuBarTitle: String {
        let total = max(0, Int(engine.remaining.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
