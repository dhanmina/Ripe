import SwiftUI

struct StatsView: View {
    @ObservedObject var engine: PomodoroEngine

    private let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    private var maxCount: Int {
        max(engine.statsLast7Days.map(\.count).max() ?? 0, 1)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label {
                Text("\(engine.statsToday) today")
                    .font(.subheadline.weight(.medium))
            } icon: {
                Image(systemName: "checkmark.seal.fill")
                    .foregroundStyle(.green)
            }

            HStack(alignment: .bottom, spacing: 8) {
                ForEach(engine.statsLast7Days, id: \.date) { entry in
                    VStack(spacing: 4) {
                        Capsule()
                            .fill(entry.count > 0 ? Color.accentColor : Color.primary.opacity(0.12))
                            .frame(width: 6, height: barHeight(for: entry.count))
                        Text(dayFormatter.string(from: entry.date))
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 36, alignment: .bottom)
        }
    }

    private func barHeight(for count: Int) -> CGFloat {
        let minHeight: CGFloat = 3
        return max(minHeight, CGFloat(count) / CGFloat(maxCount) * 24)
    }
}

#Preview {
    StatsView(engine: PomodoroEngine())
}
