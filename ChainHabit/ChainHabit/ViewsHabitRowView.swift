//
//  HabitRowView.swift
//  ChainHabit
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI
import SwiftData

struct HabitRowView: View {
    @Environment(\.modelContext) private var modelContext
    let habit: Habit
    let currentDate: Date
    let onTap: () -> Void

    @State private var isCompleted: Bool = false
    @State private var animateCheck: Bool = false

    private var canToggleCompletion: Bool {
        habit.isScheduled(on: currentDate)
    }

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {

                // Completion button
                Button {
                    toggleCompletion()
                } label: {
                    ZStack {
                        Circle()
                            .fill(isCompleted ? habit.color : habit.color.opacity(0.12))
                            .frame(width: 52, height: 52)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(.white)
                                .scaleEffect(animateCheck ? 1 : 0.5)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCheck)
                        } else {
                            Circle()
                                .strokeBorder(habit.color.opacity(0.5), lineWidth: 2)
                                .frame(width: 36, height: 36)
                        }
                    }
                }
                .buttonStyle(.plain)
                .disabled(!canToggleCompletion)

                // Habit info
                VStack(alignment: .leading, spacing: 5) {
                    Text(habit.name)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(isCompleted ? .secondary : .primary)

                    if !habit.notes.isEmpty {
                        Text(habit.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 6) {
                        Label(habit.frequency.displayName, systemImage: habit.frequency.systemImage)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        if let statusText = habit.statusText(relativeTo: currentDate) {
                            Text("·")
                                .foregroundStyle(.secondary)
                                .font(.caption)

                            Text(statusText)
                                .font(.caption.weight(.medium))
                                .foregroundStyle(habit.hasEnded(before: currentDate) ? .red : .secondary)
                        }

                        if habit.currentStreak() > 0 {
                            Text("·")
                                .foregroundStyle(.secondary)
                                .font(.caption)

                            HStack(spacing: 2) {
                                Image(systemName: "flame.fill")
                                    .foregroundStyle(.orange)
                                Text("\(habit.currentStreak()) day streak")
                                    .foregroundStyle(.orange)
                            }
                            .font(.caption.weight(.medium))
                        }
                    }
                }

                Spacer()

                // Large streak badge
                if habit.currentStreak() >= 2 {
                    VStack(spacing: 1) {
                        Text("\(habit.currentStreak())")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(.orange)
                        Image(systemName: "flame.fill")
                            .font(.system(size: 11))
                            .foregroundStyle(.orange.opacity(0.8))
                    }
                    .padding(.trailing, 4)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isCompleted
                        ? habit.color.opacity(0.07)
                        : Color(.systemBackground))
                    .shadow(
                        color: isCompleted ? habit.color.opacity(0.15) : Color.black.opacity(0.05),
                        radius: 8, y: 3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isCompleted ? habit.color.opacity(0.25) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            isCompleted = habit.isCompleted(on: currentDate)
            animateCheck = isCompleted
        }
        .onChange(of: habit.logs.count) { _, _ in
            isCompleted = habit.isCompleted(on: currentDate)
        }
        .onChange(of: currentDate) { _, newDate in
            isCompleted = habit.isCompleted(on: newDate)
            animateCheck = isCompleted
        }
    }

    private func toggleCompletion() {
        guard canToggleCompletion else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)

        if let existingLog = habit.logs.first(where: {
            calendar.isDate($0.completionDate, inSameDayAs: today)
        }) {
            modelContext.delete(existingLog)
            isCompleted = false
            animateCheck = false
            NotificationManager.shared.scheduleEveningNotification(for: habit)
        } else {
            let log = HabitLog(completionDate: today, habit: habit)
            modelContext.insert(log)
            isCompleted = true
            animateCheck = true
            NotificationManager.shared.cancelEveningNotification(for: habit)
            
            // Check for review request milestone
            NotificationManager.shared.requestReviewIfAppropriate(streak: habit.currentStreak())
        }

        try? modelContext.save()
    }
}

#Preview {
    let schema = Schema([Habit.self, HabitLog.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let habit = Habit(name: "Morning Meditation", colorHex: "9B59B6", frequency: .daily)
    let _ = {
        container.mainContext.insert(habit)
    }()

    VStack(spacing: 12) {
        HabitRowView(habit: habit, currentDate: Date()) { }
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .modelContainer(container)
}
