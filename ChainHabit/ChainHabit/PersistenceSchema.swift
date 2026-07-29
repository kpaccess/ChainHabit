//
//  PersistenceSchema.swift
//  ChainHabit
//

import Foundation
import SwiftData
import SwiftUI

enum ChainHabitSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Habit.self, HabitLog.self, TodoTask.self]
    }

    @Model
    final class Habit {
        var uuidValue: UUID?
        var name: String
        var colorHex: String
        var creationDate: Date
        var frequencyData: Data
        var morningReminderEnabledValue: Bool?
        var morningReminderTimeValue: Date?
        var eveningReminderEnabledValue: Bool?
        var eveningReminderTimeValue: Date?

        @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
        var logs: [HabitLog] = []

        init(
            uuidValue: UUID? = UUID(),
            name: String,
            colorHex: String,
            creationDate: Date = Date(),
            frequencyData: Data = Data(),
            morningReminderEnabledValue: Bool? = false,
            morningReminderTimeValue: Date? = nil,
            eveningReminderEnabledValue: Bool? = false,
            eveningReminderTimeValue: Date? = nil
        ) {
            self.uuidValue = uuidValue
            self.name = name
            self.colorHex = colorHex
            self.creationDate = creationDate
            self.frequencyData = frequencyData
            self.morningReminderEnabledValue = morningReminderEnabledValue
            self.morningReminderTimeValue = morningReminderTimeValue
            self.eveningReminderEnabledValue = eveningReminderEnabledValue
            self.eveningReminderTimeValue = eveningReminderTimeValue
        }
    }

    @Model
    final class HabitLog {
        var completionDate: Date
        var habit: Habit?

        init(completionDate: Date = Date(), habit: Habit? = nil) {
            self.completionDate = completionDate
            self.habit = habit
        }
    }

    @Model
    final class TodoTask {
        var uuid: UUID
        var title: String
        var isCompleted: Bool
        var dueDate: Date
        var creationDate: Date

        init(
            uuid: UUID = UUID(),
            title: String,
            isCompleted: Bool = false,
            dueDate: Date,
            creationDate: Date = Date()
        ) {
            self.uuid = uuid
            self.title = title
            self.isCompleted = isCompleted
            self.dueDate = dueDate
            self.creationDate = creationDate
        }
    }
}

enum ChainHabitSchemaV2: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(2, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Habit.self, HabitLog.self, TodoTask.self]
    }

    @Model
    final class Habit {
        var uuidValue: UUID?
        var name: String
        var colorHex: String
        var creationDate: Date
        var notesValue: String?
        var frequencyData: Data
        var morningReminderEnabledValue: Bool?
        var morningReminderTimeValue: Date?
        var eveningReminderEnabledValue: Bool?
        var eveningReminderTimeValue: Date?

        @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
        var logs: [HabitLog] = []

        init(
            uuidValue: UUID? = UUID(),
            name: String,
            colorHex: String,
            creationDate: Date = Date(),
            notesValue: String? = "",
            frequencyData: Data = Data(),
            morningReminderEnabledValue: Bool? = false,
            morningReminderTimeValue: Date? = nil,
            eveningReminderEnabledValue: Bool? = false,
            eveningReminderTimeValue: Date? = nil
        ) {
            self.uuidValue = uuidValue
            self.name = name
            self.colorHex = colorHex
            self.creationDate = creationDate
            self.notesValue = notesValue
            self.frequencyData = frequencyData
            self.morningReminderEnabledValue = morningReminderEnabledValue
            self.morningReminderTimeValue = morningReminderTimeValue
            self.eveningReminderEnabledValue = eveningReminderEnabledValue
            self.eveningReminderTimeValue = eveningReminderTimeValue
        }
    }

    @Model
    final class HabitLog {
        var completionDate: Date
        var habit: Habit?

        init(completionDate: Date = Date(), habit: Habit? = nil) {
            self.completionDate = completionDate
            self.habit = habit
        }
    }

    @Model
    final class TodoTask {
        var uuid: UUID
        var title: String
        var notesValue: String?
        var isCompleted: Bool
        var dueDate: Date
        var creationDate: Date
        var reminderEnabledValue: Bool?
        var reminderDateValue: Date?

        init(
            uuid: UUID = UUID(),
            title: String,
            notesValue: String? = "",
            dueDate: Date = Date(),
            isCompleted: Bool = false,
            creationDate: Date = Date(),
            reminderEnabledValue: Bool? = false,
            reminderDateValue: Date? = nil
        ) {
            self.uuid = uuid
            self.title = title
            self.notesValue = notesValue
            self.dueDate = dueDate
            self.isCompleted = isCompleted
            self.creationDate = creationDate
            self.reminderEnabledValue = reminderEnabledValue
            self.reminderDateValue = reminderDateValue
        }
    }
}

enum ChainHabitSchemaV3: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(3, 0, 0) }

    static var models: [any PersistentModel.Type] {
        [Habit.self, HabitLog.self, TodoTask.self]
    }

    @Model
    final class Habit {
        var uuidValue: UUID?
        var name: String
        var colorHex: String
        var creationDate: Date
        var notesValue: String?
        var frequencyData: Data
        var endDateValue: Date?
        var morningReminderEnabledValue: Bool?
        var morningReminderTimeValue: Date?
        var eveningReminderEnabledValue: Bool?
        var eveningReminderTimeValue: Date?

        @Relationship(deleteRule: .cascade, inverse: \HabitLog.habit)
        var logs: [HabitLog] = []

        init(
            name: String,
            colorHex: String,
            creationDate: Date = Date(),
            notes: String = "",
            frequency: Frequency = .daily,
            endDate: Date? = nil,
            morningReminderEnabled: Bool = false,
            morningReminderTime: Date = Habit.defaultMorningTime,
            eveningReminderEnabled: Bool = false,
            eveningReminderTime: Date = Habit.defaultEveningTime
        ) {
            self.uuidValue = UUID()
            self.name = name
            self.colorHex = colorHex
            self.creationDate = creationDate
            self.notesValue = notes
            self.frequencyData = Habit.encode(frequency)
            self.endDateValue = endDate
            self.morningReminderEnabledValue = morningReminderEnabled
            self.morningReminderTimeValue = morningReminderTime
            self.eveningReminderEnabledValue = eveningReminderEnabled
            self.eveningReminderTimeValue = eveningReminderTime
        }
    }

    @Model
    final class HabitLog {
        var completionDate: Date
        var habit: Habit?

        init(completionDate: Date = Date(), habit: Habit? = nil) {
            self.completionDate = completionDate
            self.habit = habit
        }
    }

    @Model
    final class TodoTask {
        var uuid: UUID
        var title: String
        var notesValue: String?
        var isCompleted: Bool
        var dueDate: Date
        var creationDate: Date
        var reminderEnabledValue: Bool?
        var reminderDateValue: Date?

        init(
            title: String,
            notes: String = "",
            dueDate: Date = TodoTask.defaultDueDate(),
            isCompleted: Bool = false,
            reminderEnabled: Bool = false,
            reminderDate: Date? = nil
        ) {
            self.uuid = UUID()
            self.title = title
            self.notesValue = notes
            self.dueDate = dueDate
            self.isCompleted = isCompleted
            self.creationDate = Date()
            self.reminderEnabledValue = reminderEnabled
            self.reminderDateValue = reminderDate ?? TodoTask.defaultReminderDate(for: dueDate)
        }
    }
}

enum ChainHabitMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [ChainHabitSchemaV1.self, ChainHabitSchemaV2.self, ChainHabitSchemaV3.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: ChainHabitSchemaV1.self, toVersion: ChainHabitSchemaV2.self),
            .lightweight(fromVersion: ChainHabitSchemaV2.self, toVersion: ChainHabitSchemaV3.self)
        ]
    }
}

typealias Habit = ChainHabitSchemaV3.Habit
typealias HabitLog = ChainHabitSchemaV3.HabitLog
typealias TodoTask = ChainHabitSchemaV3.TodoTask
