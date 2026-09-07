import Foundation

final class StatsStore {
    private let defaultsKey = "com.ripe.dailyCompletionCounts"
    private let userDefaults: UserDefaults
    private let calendar = Calendar.current

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func recordCompletion(on date: Date = Date()) {
        var counts = loadCounts()
        counts[dayKey(for: date), default: 0] += 1
        saveCounts(counts)
    }

    var today: Int {
        loadCounts()[dayKey(for: Date())] ?? 0
    }

    var allTime: Int {
        loadCounts().values.reduce(0, +)
    }

    var last7Days: [(date: Date, count: Int)] {
        let counts = loadCounts()
        return (0..<7).reversed().compactMap { offset -> (date: Date, count: Int)? in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: Date()) else {
                return nil
            }
            return (date, counts[dayKey(for: date)] ?? 0)
        }
    }

    private func dayKey(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.timeZone = calendar.timeZone
        return formatter.string(from: date)
    }

    private func loadCounts() -> [String: Int] {
        userDefaults.dictionary(forKey: defaultsKey) as? [String: Int] ?? [:]
    }

    private func saveCounts(_ counts: [String: Int]) {
        userDefaults.set(counts, forKey: defaultsKey)
    }
}
