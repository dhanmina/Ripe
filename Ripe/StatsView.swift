import SwiftUI

struct StatsView: View {
    @ObservedObject var engine: PomodoroEngine

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Today: \(engine.statsToday) 🍅")
                .font(.subheadline)

            HStack(spacing: 6) {
                ForEach(engine.statsLast7Days, id: \.date) { entry in
                    VStack(spacing: 2) {
                        Text("\(entry.count)")
                            .font(.caption2)
                        Text(dayFormatter.string(from: entry.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    StatsView(engine: PomodoroEngine())
}
