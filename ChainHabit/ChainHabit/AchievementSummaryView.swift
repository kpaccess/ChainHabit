//
//  AchievementSummaryView.swift
//  ChainHabit
//

import SwiftUI
import Charts
import SwiftData

struct AchievementSummaryView: View {
    let habits: [Habit]
    let currentDate: Date
    @Environment(\.dismiss) private var dismiss

    private var completedToday: [Habit] {
        habits.filter { $0.isCompleted(on: currentDate) }
    }

    private struct DayData: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
    }

    private var last7DaysData: [DayData] {
        (0..<7).reversed().map { offset in
            let date = currentDate.daysAgo(offset)
            let count = habits.filter { $0.isCompleted(on: date) }.count
            return DayData(label: date.dayName(), count: count)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle
            Capsule()
                .fill(Color.secondary.opacity(0.3))
                .frame(width: 40, height: 4)
                .padding(.top, 12)

            ScrollView {
                VStack(spacing: 24) {
                    // Star + title
                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(Color.yellow.opacity(0.15))
                                .frame(width: 100, height: 100)

                            Image(systemName: "star.fill")
                                .font(.system(size: 52))
                                .foregroundStyle(Color.yellow)
                                .symbolEffect(.bounce, value: true)
                        }

                        Text("Achievement Summary")
                            .font(.title2.bold())

                        Text(currentDate.formatted(.dateTime.weekday(.wide).month().day()))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.top, 12)

                    // Completed habits list
                    VStack(alignment: .leading, spacing: 0) {
                        Text("Completed Today")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.bottom, 12)

                        ForEach(completedToday) { habit in
                            HStack(spacing: 14) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(habit.color)
                                    .font(.title3)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(habit.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(habit.frequency.displayName)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if habit.currentStreak() > 1 {
                                    HStack(spacing: 3) {
                                        Image(systemName: "flame.fill")
                                            .foregroundStyle(.orange)
                                        Text("\(habit.currentStreak())")
                                            .foregroundStyle(.orange)
                                            .fontWeight(.semibold)
                                    }
                                    .font(.caption)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 10)

                            if habit.id != completedToday.last?.id {
                                Divider().padding(.leading, 52)
                            }
                        }
                    }
                    .padding(.vertical, 12)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Weekly bar chart
                    VStack(alignment: .leading, spacing: 12) {
                        Text("This Week")
                            .font(.headline)

                        Chart(last7DaysData) { item in
                            BarMark(
                                x: .value("Day", item.label),
                                y: .value("Completed", item.count)
                            )
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "9B59B6") ?? .purple, Color(hex: "5B6FD4") ?? .indigo],
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                            .cornerRadius(5)
                        }
                        .frame(height: 130)
                        .chartYAxis {
                            AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Done button
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "9B59B6") ?? .purple, Color(hex: "5B6FD4") ?? .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(Capsule())
                            .shadow(color: .purple.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 32)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

#Preview {
    let schema = Schema([Habit.self, HabitLog.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let ctx = container.mainContext

    let h1 = Habit(name: "Morning Workout", colorHex: "E74C3C", frequency: .daily)
    let h2 = Habit(name: "Read 30 min", colorHex: "3498DB", frequency: .daily)
    let h3 = Habit(name: "Meditate", colorHex: "9B59B6", frequency: .daily)
    let _ = {
        ctx.insert(h1); ctx.insert(h2); ctx.insert(h3)
        ctx.insert(HabitLog(completionDate: Date(), habit: h1))
        ctx.insert(HabitLog(completionDate: Date().daysAgo(1), habit: h1))
        ctx.insert(HabitLog(completionDate: Date(), habit: h2))
        ctx.insert(HabitLog(completionDate: Date().daysAgo(1), habit: h2))
        ctx.insert(HabitLog(completionDate: Date(), habit: h3))
        ctx.insert(HabitLog(completionDate: Date().daysAgo(1), habit: h3))
    }()

    AchievementSummaryView(habits: [h1, h2, h3], currentDate: Date())
        .modelContainer(container)
}
