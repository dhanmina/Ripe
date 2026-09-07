import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var engine: PomodoroEngine
    @ObservedObject var settingsStore: SettingsStore
    @ObservedObject var notificationManager: NotificationManager
    @StateObject private var loginItemManager = LoginItemManager()
    @State private var showingSettings = false
    @State private var showingQuitConfirmation = false

    private var progress: CGFloat {
        CGFloat(engine.remaining / engine.phaseDuration)
    }

    var body: some View {
        Group {
            if showingQuitConfirmation {
                quitConfirmContent
            } else if showingSettings {
                settingsContent
            } else {
                timerContent
            }
        }
        .padding(16)
        .frame(width: 240)
    }

    private var timerContent: some View {
        VStack(spacing: 16) {
            header

            ZStack {
                Circle()
                    .stroke(.quaternary, lineWidth: 8)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        engine.phase.tint.gradient,
                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .animation(.linear(duration: 1), value: engine.remaining)

                Text(timeString(from: engine.remaining))
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .monospacedDigit()
            }
            .frame(width: 140, height: 140)

            controls

            Divider()

            StatsView(engine: engine)
        }
    }

    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            settingsHeader

            ScrollView {
                SettingsView(
                    loginItemManager: loginItemManager,
                    settingsStore: settingsStore,
                    notificationManager: notificationManager,
                    engine: engine
                )
                .padding(.trailing, 10)
            }
            .scrollContentBackground(.hidden)
            .background(Color.clear)
            .frame(maxHeight: 360)
        }
        .frame(minHeight: 140)
    }

    private var quitConfirmContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "power.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.red)

            Text("Quit Ripe?")
                .font(.headline)

            Text("Your timer will stop. Today's completed sessions stay saved.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Button("Cancel") {
                    showingQuitConfirmation = false
                }
                .buttonStyle(.bordered)

                Button("Quit") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 8)
        .frame(minHeight: 140)
    }

    private var settingsHeader: some View {
        HStack {
            Button {
                showingSettings = false
            } label: {
                Image(systemName: "chevron.backward")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Back")

            Text("Settings")
                .font(.headline)

            Spacer()
        }
    }

    private var header: some View {
        HStack {
            Label(engine.phase.label, systemImage: engine.phase.symbolName)
                .font(.headline)
                .foregroundStyle(engine.phase.tint)

            Spacer()

            Button {
                showingSettings = true
            } label: {
                Image(systemName: "gearshape")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Settings")

            Button {
                showingQuitConfirmation = true
            } label: {
                Image(systemName: "power")
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
            .accessibilityLabel("Quit Ripe")
        }
    }

    private var controls: some View {
        HStack(spacing: 20) {
            Button {
                engine.reset()
            } label: {
                Image(systemName: "gobackward")
                    .imageScale(.large)
            }
            .accessibilityLabel("Reset")

            Button {
                if engine.runState == .running {
                    engine.pause()
                } else {
                    engine.start()
                }
            } label: {
                Image(systemName: engine.runState == .running ? "pause.fill" : "play.fill")
                    .imageScale(.large)
            }
            .tint(engine.phase.tint)
            .controlSize(.extraLarge)
            .accessibilityLabel(engine.runState == .running ? "Pause" : "Start")

            Button {
                engine.skip()
            } label: {
                Image(systemName: "forward.end.fill")
                    .imageScale(.large)
            }
            .accessibilityLabel("Skip")
        }
        .buttonStyle(.bordered)
        .buttonBorderShape(.circle)
        .controlSize(.large)
    }

    private func timeString(from interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

#Preview {
    let settingsStore = SettingsStore()
    MenuBarView(
        engine: PomodoroEngine(settingsStore: settingsStore),
        settingsStore: settingsStore,
        notificationManager: NotificationManager(settingsStore: settingsStore)
    )
}
