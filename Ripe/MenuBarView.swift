import SwiftUI

struct MenuBarView: View {
    @ObservedObject var engine: PomodoroEngine

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(engine.phase.label)
                .font(.headline)

            Text(timeString(from: engine.remaining))
                .font(.system(size: 36, weight: .medium, design: .monospaced))

            HStack {
                Button(engine.runState == .running ? "Pause" : "Start") {
                    if engine.runState == .running {
                        engine.pause()
                    } else {
                        engine.start()
                    }
                }
                Button("Reset") { engine.reset() }
                Button("Skip") { engine.skip() }
            }

            Divider()

            StatsView(engine: engine)
        }
        .padding()
        .frame(width: 220)
    }

    private func timeString(from interval: TimeInterval) -> String {
        let total = max(0, Int(interval.rounded()))
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}

#Preview {
    MenuBarView(engine: PomodoroEngine())
}
