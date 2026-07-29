//
//  Habit.swift
//  ChainHabit
//

import SwiftUI
import Foundation
import SwiftData

extension Habit {
    var uuid: UUID {
        get {
            if let value = uuidValue {
                return value
            }
            let newValue = UUID()
            uuidValue = newValue
            return newValue
        }
        set { uuidValue = newValue }
    }

    var morningReminderEnabled: Bool {
        get { morningReminderEnabledValue ?? false }
        set { morningReminderEnabledValue = newValue }
    }

    var morningReminderTime: Date {
        get { morningReminderTimeValue ?? Habit.defaultMorningTime }
        set { morningReminderTimeValue = newValue }
    }

    var eveningReminderEnabled: Bool {
        get { eveningReminderEnabledValue ?? false }
        set { eveningReminderEnabledValue = newValue }
    }

    var eveningReminderTime: Date {
        get { eveningReminderTimeValue ?? Habit.defaultEveningTime }
        set { eveningReminderTimeValue = newValue }
    }

    var notes: String {
        get { notesValue ?? "" }
        set { notesValue = newValue }
    }

    var endDate: Date? {
        get { endDateValue }
        set { endDateValue = newValue }
    }

    static var defaultMorningTime: Date {
        Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date()) ?? Date()
    }

    static var defaultEveningTime: Date {
        Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date()) ?? Date()
    }

    var frequency: Frequency {
        get { Habit.decode(frequencyData) }
        set { frequencyData = Habit.encode(newValue) }
    }

    static func encode(_ frequency: Frequency) -> Data {
        (try? JSONEncoder().encode(frequency)) ?? Data()
    }

    static func decode(_ data: Data) -> Frequency {
        (try? JSONDecoder().decode(Frequency.self, from: data)) ?? .daily
    }

    enum Frequency: Codable, Equatable {
        case daily
        case weekly
        case customDays(Set<Int>)
        case everyXDays(Int)
        case monthly

        var displayName: String {
            switch self {
            case .daily:
                return "Daily"
            case .weekly:
                return "Weekly"
            case .customDays(let days):
                if days.count == 7 {
                    return "Daily"
                } else if days.count == 1, let day = days.first {
                    return "Every \(dayName(for: day))"
                } else {
                    return "\(days.count) days/week"
                }
            case .everyXDays(let interval):
                return interval == 1 ? "Daily" : "Every \(interval) days"
            case .monthly:
                return "Monthly"
            }
        }

        var systemImage: String {
            switch self {
            case .daily:
                return "sun.max.fill"
            case .weekly:
                return "calendar.badge.clock"
            case .customDays:
                return "calendar"
            case .everyXDays:
                return "arrow.clockwise"
            case .monthly:
                return "calendar.circle"
            }
        }

        private func dayName(for day: Int) -> String {
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            return formatter.weekdaySymbols[day - 1]
        }

        func isScheduled(for date: Date) -> Bool {
            let calendar = Calendar.current
            switch self {
            case .daily:
                return true
            case .weekly:
                return true
            case .customDays(let scheduledDays):
                let weekday = calendar.component(.weekday, from: date)
                return scheduledDays.contains(weekday)
            case .everyXDays:
                return true
            case .monthly:
                return true
            }
        }

        static var allSimpleCases: [Frequency] {
            [.daily, .weekly, .monthly]
        }
    }

    var color: Color {
        Color(hex: colorHex) ?? .blue
    }

    var totalCompletions: Int {
        logs.count
    }

    func isCompletedToday() -> Bool {
        let calendar = Calendar.current
        return logs.contains { calendar.isDateInToday($0.completionDate) }
    }

    func currentStreak() -> Int {
        let calendar = Calendar.current
        let sortedLogs = logs.sorted { $0.completionDate > $1.completionDate }

        guard let mostRecent = sortedLogs.first else { return 0 }

        let daysBetween = calendar.dateComponents([.day], from: mostRecent.completionDate, to: Date()).day ?? 0
        guard daysBetween <= 1 else { return 0 }

        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())

        for log in sortedLogs {
            let logDate = calendar.startOfDay(for: log.completionDate)
            if calendar.isDate(logDate, inSameDayAs: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else if logDate < currentDate {
                break
            }
        }

        return streak
    }

    func isCompleted(on date: Date) -> Bool {
        let calendar = Calendar.current
        return logs.contains { calendar.isDate($0.completionDate, inSameDayAs: date) }
    }

    func isScheduled(on date: Date) -> Bool {
        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        let startDate = calendar.startOfDay(for: creationDate)

        guard targetDate >= startDate else { return false }

        if let endDate, targetDate > calendar.startOfDay(for: endDate) {
            return false
        }

        switch frequency {
        case .daily:
            return true
        case .weekly:
            let daysSinceCreation = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
            return daysSinceCreation >= 0 && daysSinceCreation % 7 == 0
        case .customDays(let days):
            return days.contains(calendar.component(.weekday, from: targetDate))
        case .everyXDays(let interval):
            let daysSinceCreation = calendar.dateComponents(
                [.day],
                from: startDate,
                to: targetDate
            ).day ?? 0
            return daysSinceCreation >= 0 && daysSinceCreation % interval == 0
        case .monthly:
            return calendar.component(.day, from: creationDate) == calendar.component(.day, from: targetDate)
        }
    }

    func hasEnded(before date: Date) -> Bool {
        guard let endDate else { return false }
        return Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: endDate)
    }

    func statusText(relativeTo date: Date = Date()) -> String? {
        guard let endDate else { return nil }

        let calendar = Calendar.current
        let targetDate = calendar.startOfDay(for: date)
        let finalDate = calendar.startOfDay(for: endDate)

        if targetDate > finalDate {
            return "Ended \(endDate.formatted(date: .abbreviated, time: .omitted))"
        }

        if targetDate == finalDate {
            return "Ends today"
        }

        if let daysRemaining = calendar.dateComponents([.day], from: targetDate, to: finalDate).day {
            if daysRemaining == 1 {
                return "Ends tomorrow"
            }
            return "Ends in \(daysRemaining) days"
        }

        return "Ends \(endDate.formatted(date: .abbreviated, time: .omitted))"
    }

    func toggleCompletion(for date: Date, in context: ModelContext) {
        guard isScheduled(on: date) else { return }

        if let existingLog = logs.first(where: {
            Calendar.current.isDate($0.completionDate, inSameDayAs: date)
        }) {
            context.delete(existingLog)
            NotificationManager.shared.scheduleEveningNotification(for: self)
        } else {
            let newLog = HabitLog(completionDate: date, habit: self)
            context.insert(newLog)
            NotificationManager.shared.cancelEveningNotification(for: self)
            NotificationManager.shared.requestReviewIfAppropriate(streak: currentStreak() + 1)
        }

        try? context.save()
    }
}
