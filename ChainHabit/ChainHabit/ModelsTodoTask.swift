//
//  TodoTask.swift
//  ChainHabit
//

import Foundation

extension TodoTask {
    var notes: String {
        get { notesValue ?? "" }
        set { notesValue = newValue }
    }

    var reminderEnabled: Bool {
        get { reminderEnabledValue ?? false }
        set { reminderEnabledValue = newValue }
    }

    var reminderDate: Date {
        get { reminderDateValue ?? TodoTask.defaultReminderDate(for: dueDate) }
        set { reminderDateValue = newValue }
    }

    static func defaultDueDate(on date: Date = Date()) -> Date {
        Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: date) ?? date
    }

    static func defaultReminderDate(for dueDate: Date) -> Date {
        let thirtyMinutesEarlier = Calendar.current.date(byAdding: .minute, value: -30, to: dueDate) ?? dueDate
        return min(thirtyMinutesEarlier, dueDate)
    }
}
