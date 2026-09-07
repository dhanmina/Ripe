import SwiftUI

struct SettingsView: View {
    @ObservedObject var loginItemManager: LoginItemManager
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var notificationManager: NotificationManager
    @ObservedObject var engine: PomodoroEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            sectionHeader("Timer")
            durationRow(title: "Focus", minutes: $settingsStore.workMinutes, range: 5...90)
            durationRow(title: "Short Break", minutes: $settingsStore.shortBreakMinutes, range: 1...30)
            durationRow(title: "Long Break", minutes: $settingsStore.longBreakMinutes, range: 5...60)
            countRow(title: "Sessions Before Long Break", value: $settingsStore.sessionsBeforeLongBreak, range: 1...12)

            if engine.runState != .idle {
                Text("Duration changes apply to the next session.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            sectionHeader("Notifications")
            soundRow

            Divider()

            sectionHeader("General")
            loginRow
        }
        .onAppear {
            loginItemManager.refresh()
            notificationManager.refreshAuthorizationState()
        }
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption)
            .foregroundStyle(.secondary)
            .textCase(.uppercase)
    }

    private var loginRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Toggle(isOn: Binding(
                get: { loginItemManager.isEnabled },
                set: { loginItemManager.setEnabled($0) }
            )) {
                Text("Launch at Login")
                    .font(.subheadline)
            }
            .toggleStyle(.switch)

            if let message = loginItemManager.lastErrorMessage {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)

                Button("Open Login Items Settings") {
                    loginItemManager.openSystemSettings()
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    private var soundRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            Picker("Sound", selection: $settingsStore.soundName) {
                ForEach(NotificationSoundOption.allCases) { option in
                    Text(option.rawValue).tag(option.rawValue)
                }
            }
            .font(.subheadline)
            .onChange(of: settingsStore.soundName) { _, newValue in
                (NotificationSoundOption(rawValue: newValue) ?? .system).play()
            }

            if notificationManager.authorizationState == .denied {
                Text("Notifications are turned off for Ripe.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("Open Notification Settings") {
                    notificationManager.openSystemSettings()
                }
                .font(.caption)
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)
            }
        }
    }

    private func durationRow(title: String, minutes: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            TextField("", value: clamped(minutes, to: range), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 36)
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
                .monospacedDigit()
            Text("min")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func countRow(title: String, value: Binding<Int>, range: ClosedRange<Int>) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .lineLimit(1)
            Spacer()
            TextField("", value: clamped(value, to: range), format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 36)
                .multilineTextAlignment(.trailing)
                .font(.subheadline)
                .monospacedDigit()
        }
    }

    private func clamped(_ binding: Binding<Int>, to range: ClosedRange<Int>) -> Binding<Int> {
        Binding(
            get: { binding.wrappedValue },
            set: { binding.wrappedValue = min(max($0, range.lowerBound), range.upperBound) }
        )
    }
}

#Preview {
    let settingsStore = SettingsStore()
    SettingsView(
        loginItemManager: LoginItemManager(),
        settingsStore: settingsStore,
        notificationManager: NotificationManager(settingsStore: settingsStore),
        engine: PomodoroEngine(settingsStore: settingsStore)
    )
}
