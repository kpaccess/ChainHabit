//
//  HabitListView.swift
//  ChainHabit
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI
import SwiftData

struct HabitListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Query(sort: \Habit.creationDate) private var habits: [Habit]
    @Query(sort: \TodoTask.dueDate) private var todoTasks: [TodoTask]

    @State private var showingAddHabit = false
    @State private var selectedHabit: Habit?
    @State private var showingAddTodoTask = false
    @State private var selectedTodoTask: TodoTask?
    @State private var taskToConvert: TodoTask?
    @State private var searchText = ""
    @State private var showingAchievement = false
    @AppStorage("lastAchievementDate") private var lastAchievementDate = ""
    @State private var currentDate = Date()

    private var scheduledHabits: [Habit] {
        habits.filter { $0.isScheduled(on: currentDate) }
    }

    // Filtered habits based on today's schedule OR search across all habits
    private var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return scheduledHabits
        } else {
            // Search across ALL habits when typing
            return habits.filter { habit in
                habit.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var filteredTodoTasks: [TodoTask] {
        if searchText.isEmpty {
            let calendar = Calendar.current
            let startOfCurrent = calendar.startOfDay(for: currentDate)
            
            return todoTasks.filter { task in
                calendar.isDate(task.dueDate, inSameDayAs: startOfCurrent) ||
                (!task.isCompleted && task.dueDate < startOfCurrent)
            }
        } else {
            // Search across ALL tasks when typing, regardless of date
            return todoTasks.filter {
                $0.title.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    private var totalScheduledCount: Int {
        scheduledHabits.count + filteredTodoTasks.count
    }

    private var totalCompletedCount: Int {
        let habitsCompleted = scheduledHabits.filter { $0.isCompleted(on: currentDate) }.count
        let todosCompleted = filteredTodoTasks.filter { $0.isCompleted }.count
        return habitsCompleted + todosCompleted
    }

    private var progress: Double {
        totalScheduledCount == 0 ? 0 : Double(totalCompletedCount) / Double(totalScheduledCount)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        if !scheduledHabits.isEmpty || !filteredTodoTasks.isEmpty {
                            progressHeader
                        }

                        if habits.isEmpty && todoTasks.isEmpty {
                            emptyStateView
                                .padding(.top, 60)
                        } else if !searchText.isEmpty && filteredHabits.isEmpty && filteredTodoTasks.isEmpty {
                            searchEmptyStateView
                                .padding(.top, 60)
                        } else {
                            habitsSection
                            todoSection
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("ChainHabit")
            .navigationBarTitleDisplayMode(.large)
            .searchable(
                text: $searchText,
                placement: .navigationBarDrawer(displayMode: .always),
                prompt: "Search habits and tasks"
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button {
                            showingAddHabit = true
                        } label: {
                            Label("New Habit", systemImage: "link.circle")
                        }

                        Button {
                            showingAddTodoTask = true
                        } label: {
                            Label("New Task", systemImage: "checkmark.circle")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.purple)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddEditHabitView()
            }
            .sheet(item: $taskToConvert) { task in
                AddEditHabitView(initialName: task.title)
            }
            .sheet(isPresented: $showingAddTodoTask) {
                AddEditTodoTaskView(initialDate: currentDate)
            }
            .sheet(item: $selectedHabit) { habit in
                HabitDetailView(habit: habit)
            }
            .sheet(item: $selectedTodoTask) { task in
                AddEditTodoTaskView(taskToEdit: task, initialDate: currentDate)
            }
            .sheet(isPresented: $showingAchievement) {
                AchievementSummaryView(habits: scheduledHabits, currentDate: currentDate)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.hidden)
            }
            .onChange(of: totalCompletedCount) { _, newCount in
                let today = currentDate.formattedShort()
                if newCount == totalScheduledCount && totalScheduledCount > 0 && lastAchievementDate != today {
                    lastAchievementDate = today
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        showingAchievement = true
                    }
                }
            }
            .onChange(of: scenePhase) { _, phase in
                if phase == .active {
                    currentDate = Date()
                    NotificationManager.shared.refreshEveningNotifications(for: habits)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSCalendarDayChanged)) { _ in
                currentDate = Date()
            }
        }
    }

    private func deleteHabit(_ habit: Habit) {
        NotificationManager.shared.cancelNotifications(for: habit)
        modelContext.delete(habit)
    }

    private func deleteTodoTask(_ task: TodoTask) {
        NotificationManager.shared.cancelReminder(for: task)
        modelContext.delete(task)
        try? modelContext.save()
    }

    // MARK: - Progress Header

    private var progressHeader: some View {
        HStack(spacing: 20) {
            // Circular progress ring
            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.25), lineWidth: 9)
                    .frame(width: 80, height: 80)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(duration: 0.6), value: progress)

                VStack(spacing: 0) {
                    Text("\(totalCompletedCount)")
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                    Text("of \(totalScheduledCount)")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(currentDate.formatted(.dateTime.weekday(.wide).month().day()))
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))

                Text(progressMessage)
                    .font(.title3.bold())
                    .foregroundStyle(.white)

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.25))
                            .frame(height: 6)
                        Capsule()
                            .fill(Color.white)
                            .frame(width: geo.size.width * progress, height: 6)
                            .animation(.spring(duration: 0.6), value: progress)
                    }
                }
                .frame(height: 6)
            }

            Spacer()
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "9B59B6") ?? .purple,
                    Color(hex: "5B6FD4") ?? .indigo
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: (Color(hex: "9B59B6") ?? .purple).opacity(0.35), radius: 12, y: 6)
        .padding(.horizontal)
    }

    private var progressMessage: String {
        if totalScheduledCount == 0 { return "No tasks or habits due" }
        switch progress {
        case 0:       return "Let's get started! 💪"
        case 0..<0.5: return "Keep going! 🔥"
        case 0.5..<1: return "Almost there! ⭐️"
        default:      return "All done! Amazing! 🎉"
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private var habitsSection: some View {
        if !filteredHabits.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("HABITS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .padding(.horizontal)

                LazyVStack(spacing: 12) {
                    ForEach(filteredHabits) { habit in
                        HabitRowView(habit: habit, currentDate: currentDate) {
                            selectedHabit = habit
                        }
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteHabit(habit)
                            } label: {
                                Label("Delete Habit", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    @ViewBuilder
    private var todoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("TODAY'S TO-DO")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)

                Spacer()

                Button {
                    showingAddTodoTask = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.purple)
                }
            }
            .padding(.horizontal)

            if filteredTodoTasks.isEmpty {
                Text("No tasks for today. Tap + to add one!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 32)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .strokeBorder(
                                Color.secondary.opacity(0.2),
                                style: StrokeStyle(lineWidth: 1.5, dash: [5])
                            )
                    )
                    .padding(.horizontal)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredTodoTasks) { task in
                        TodoTaskRowView(task: task, onToggle: {
                            // Trigger redraw
                        }, onTap: {
                            selectedTodoTask = task
                        })
                        .contextMenu {
                            Button {
                                taskToConvert = task
                            } label: {
                                Label("Turn into Habit", systemImage: "arrow.triangle.2.circlepath")
                            }

                            Divider()

                            Button {
                                selectedTodoTask = task
                            } label: {
                                Label("Edit Task", systemImage: "pencil")
                            }

                            Button(role: .destructive) {
                                deleteTodoTask(task)
                            } label: {
                                Label("Delete Task", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    // MARK: - Empty State

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "link.circle.fill")
                .font(.system(size: 64))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.purple)

            VStack(spacing: 8) {
                Text("No Habits Yet")
                    .font(.title2.bold())
                Text("Add your first habit and\nstart building your chain.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                showingAddHabit = true
            } label: {
                Label("Add First Habit", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
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
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
    
    // MARK: - Search Empty State
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("No Results")
                    .font(.title2.bold())
                Text("No habits match '\(searchText)'")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
    }
}

#Preview {
    HabitListView()
        .modelContainer(previewContainer)
}

// MARK: - Preview Helper
@MainActor
private var previewContainer: ModelContainer {
    let schema = Schema([Habit.self, HabitLog.self, TodoTask.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    let context = container.mainContext

    let habit1 = Habit(name: "Morning Meditation", colorHex: "9B59B6", frequency: .daily)
    let habit2 = Habit(name: "Exercise", colorHex: "E74C3C", frequency: .daily)
    let task1 = TodoTask(title: "Call Apple Support", notes: "Ask about subscription billing")
    let task2 = TodoTask(title: "Buy Groceries", notes: "Milk, fruit, and bread", isCompleted: false)

    let _ = {
        context.insert(habit1)
        context.insert(habit2)
        let log = HabitLog(completionDate: Date(), habit: habit1)
        context.insert(log)
        context.insert(task1)
        context.insert(task2)
    }()

    return container
}
