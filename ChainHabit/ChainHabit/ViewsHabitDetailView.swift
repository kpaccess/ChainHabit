//
//  HabitDetailView.swift
//  HabitTracker
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI
import SwiftData
import Charts

struct HabitDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let habit: Habit
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false
    
    private let historyDays = 14
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with color and stats
                    headerSection

                    if !habit.notes.isEmpty {
                        notesSection
                    }
                    
                    // Stats cards
                    statsSection

                    // Weekly bar chart
                    weeklyChartSection

                    // History calendar
                    historySection
                }
                .padding()
            }
            .navigationTitle(habit.name)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingEditSheet = true
                        } label: {
                            Label("Edit Habit", systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete Habit", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingEditSheet) {
                AddEditHabitView(habitToEdit: habit)
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    deleteHabit()
                }
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(habit.color.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                if habit.isCompletedToday() {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundStyle(habit.color)
                } else {
                    Circle()
                        .strokeBorder(habit.color, lineWidth: 3)
                        .frame(width: 60, height: 60)
                }
            }
            
            Text(habit.name)
                .font(.title2)
                .fontWeight(.bold)
            
            Label(habit.frequency.displayName, systemImage: habit.frequency.systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if let statusText = habit.statusText() {
                Label(statusText, systemImage: "calendar.badge.exclamationmark")
                    .font(.subheadline)
                    .foregroundStyle(habit.hasEnded(before: Date()) ? .red : .secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(habit.color.opacity(0.1))
        .cornerRadius(16)
    }
    
    private struct WeekData: Identifiable {
        let id = UUID()
        let label: String
        let count: Int
    }

    private var weeklyData: [WeekData] {
        let calendar = Calendar.current
        return (0..<5).reversed().map { weekOffset in
            let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: Date().startOfWeek()) ?? Date()
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart) ?? Date()
            let count = habit.logs.filter { $0.completionDate >= weekStart && $0.completionDate < weekEnd }.count
            let label = weekStart.monthDayFormat()
            return WeekData(label: label, count: count)
        }
    }

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weekly Completions")
                .font(.headline)

            Chart(weeklyData) { item in
                BarMark(
                    x: .value("Week", item.label),
                    y: .value("Completions", item.count)
                )
                .foregroundStyle(habit.color.gradient)
                .cornerRadius(6)
            }
            .frame(height: 140)
            .chartYAxis {
                AxisMarks(position: .leading, values: .automatic(desiredCount: 4))
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Notes")
                .font(.headline)

            Text(habit.notes)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }

    private var statsSection: some View {
        HStack(spacing: 12) {
            StatCard(
                title: "Current Streak",
                value: "\(habit.currentStreak())",
                subtitle: "days",
                icon: "flame.fill",
                color: .orange
            )
            
            StatCard(
                title: "Total",
                value: "\(habit.totalCompletions)",
                subtitle: "completions",
                icon: "checkmark.seal.fill",
                color: habit.color
            )
        }
    }
    
    private var historySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Last \(historyDays) Days")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 12) {
                ForEach(0..<historyDays, id: \.self) { dayOffset in
                    let date = Date().daysAgo(historyDays - 1 - dayOffset)
                    DayCell(date: date, isCompleted: habit.isCompleted(on: date), color: habit.color)
                }
            }
            
            // Legend
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Circle()
                        .fill(habit.color)
                        .frame(width: 12, height: 12)
                    Text("Completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                HStack(spacing: 4) {
                    Circle()
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                        .frame(width: 12, height: 12)
                    Text("Not completed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(16)
    }
    
    private func deleteHabit() {
        NotificationManager.shared.cancelNotifications(for: habit)
        modelContext.delete(habit)
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            
            Text(subtitle)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
    }
}

struct DayCell: View {
    let date: Date
    let isCompleted: Bool
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(date.dayName())
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            ZStack {
                if isCompleted {
                    Circle()
                        .fill(color)
                } else {
                    Circle()
                        .strokeBorder(Color.secondary.opacity(0.3), lineWidth: 1)
                }
            }
            .frame(width: 36, height: 36)
            .overlay {
                Text("\(Calendar.current.component(.day, from: date))")
                    .font(.caption)
                    .fontWeight(isCompleted ? .semibold : .regular)
                    .foregroundStyle(isCompleted ? .white : .primary)
            }
        }
    }
}

#Preview {
    let schema = Schema([Habit.self, HabitLog.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let habit = Habit(name: "Morning Meditation", colorHex: "9B59B6", frequency: .daily)
    container.mainContext.insert(habit)
    
    // Add some logs
    for dayOffset in [0, 1, 2, 4, 5, 8, 9, 10] {
        let log = HabitLog(completionDate: Date().daysAgo(dayOffset), habit: habit)
        container.mainContext.insert(log)
    }
    
    return HabitDetailView(habit: habit)
        .modelContainer(container)
}
