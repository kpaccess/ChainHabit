//
//  NotificationManager.swift
//  ChainHabit
//

import UserNotifications
import Foundation
import StoreKit
import SwiftUI

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    func requestReviewIfAppropriate(streak: Int) {
        // Trigger review request if user hits a 7-day milestone
        if streak == 7 {
            DispatchQueue.main.async {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }
    }

    func scheduleNotifications(for habit: Habit) {
        cancelNotifications(for: habit)
        guard !habit.hasEnded(before: Date()) else { return }

        if habit.morningReminderEnabled {
            schedule(
                id: morningID(for: habit),
                title: "Time for your habit!",
                body: "Don't forget: \(habit.name)",
                time: habit.morningReminderTime
            )
        }

        if habit.eveningReminderEnabled && !habit.isCompletedToday() {
            schedule(
                id: eveningID(for: habit),
                title: "Don't break your streak!",
                body: "\(habit.name) is still waiting for you today.",
                time: habit.eveningReminderTime
            )
        }
    }

    func cancelNotifications(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [morningID(for: habit), eveningID(for: habit)]
        )
    }

    func cancelEveningNotification(for habit: Habit) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [eveningID(for: habit)]
        )
    }

    func scheduleEveningNotification(for habit: Habit) {
        guard habit.eveningReminderEnabled, !habit.hasEnded(before: Date()) else { return }
        schedule(
            id: eveningID(for: habit),
            title: "Don't break your streak!",
            body: "\(habit.name) is still waiting for you today.",
            time: habit.eveningReminderTime
        )
    }

    // Called when app becomes active on a new day — restores evening notifications for incomplete habits.
    func refreshEveningNotifications(for habits: [Habit]) {
        for habit in habits {
            UNUserNotificationCenter.current().removePendingNotificationRequests(
                withIdentifiers: [eveningID(for: habit)]
            )
            if habit.eveningReminderEnabled && !habit.isCompletedToday() && !habit.hasEnded(before: Date()) {
                scheduleEveningNotification(for: habit)
            }
        }
    }

    func scheduleReminder(for task: TodoTask) {
        cancelReminder(for: task)
        guard task.reminderEnabled, !task.isCompleted, task.reminderDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = "Task reminder"
        content.body = "\(task.title) is due at \(task.dueDate.formattedTime())."
        content.sound = .default

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: task.reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: taskReminderID(for: task), content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancelReminder(for task: TodoTask) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [taskReminderID(for: task)]
        )
    }

    private func schedule(id: String, title: String, body: String, time: Date) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    private func morningID(for habit: Habit) -> String { "morning-\(habit.uuid.uuidString)" }
    private func eveningID(for habit: Habit) -> String { "evening-\(habit.uuid.uuidString)" }
    private func taskReminderID(for task: TodoTask) -> String { "task-\(task.uuid.uuidString)" }
}
