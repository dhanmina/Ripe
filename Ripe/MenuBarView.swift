import AppKit
import SwiftUI

struct MenuBarView: View {
    @ObservedObject var engine: PomodoroEngine
    @StateObject private var loginItemManager = LoginItemManager()

    private var progress: CGFloat {
        CGFloat(engine.remaining / engine.phase.duration)
    }

    var body: some View {
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

            Divider()

            Toggle(isOn: Binding(
                get: { loginItemManager.isEnabled },
                set: { loginItemManager.setEnabled($0) }
            )) {
                Text("Launch at Login")
                    .font(.subheadline)
            }
            .toggleStyle(.switch)
        }
        .padding(16)
        .frame(width: 240)
    }

    private var header: some View {
        HStack {
            Label(engine.phase.label, systemImage: engine.phase.symbolName)
                .font(.headline)
                .foregroundStyle(engine.phase.tint)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
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
    MenuBarView(engine: PomodoroEngine())
}
