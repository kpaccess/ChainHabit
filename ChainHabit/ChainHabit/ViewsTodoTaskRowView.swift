//
//  TodoTaskRowView.swift
//  ChainHabit
//
//  Created by Krishna pradhan on 2026-05-28.
//

import SwiftUI
import SwiftData

struct TodoTaskRowView: View {
    @Environment(\.modelContext) private var modelContext
    let task: TodoTask
    let onToggle: () -> Void
    let onTap: () -> Void

    @State private var isCompleted: Bool = false
    @State private var animateCheck: Bool = false

    var body: some View {
        Button {
            onTap()
        } label: {
            HStack(spacing: 14) {
                // Checkbox button
                Button {
                    toggleTaskCompletion()
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isCompleted ? Color.purple : Color.purple.opacity(0.12))
                            .frame(width: 26, height: 26)

                        if isCompleted {
                            Image(systemName: "checkmark")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(.white)
                                .scaleEffect(animateCheck ? 1 : 0.5)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: animateCheck)
                        } else {
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color.purple.opacity(0.5), lineWidth: 2)
                                .frame(width: 26, height: 26)
                        }
                    }
                }
                .buttonStyle(.plain)

                // Task title
                VStack(alignment: .leading, spacing: 2) {
                    Text(task.title)
                        .font(.system(size: 16, weight: .medium))
                        .strikethrough(isCompleted, color: .secondary.opacity(0.6))
                        .foregroundStyle(isCompleted ? .secondary : .primary)

                    if !task.notes.isEmpty {
                        Text(task.notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }

                    HStack(spacing: 6) {
                        Label(task.dueDate.formattedTime(), systemImage: "clock")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.secondary)

                        if task.reminderEnabled {
                            Text("·")
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            Label(task.reminderDate.formattedTime(), systemImage: "bell")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !isCompleted && task.dueDate < .now {
                        Label("Overdue", systemImage: "clock.arrow.circlepath")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.orange)
                    }
                }
                .animation(.linear(duration: 0.2), value: isCompleted)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(isCompleted
                        ? Color.purple.opacity(0.04)
                        : Color(.systemBackground))
                    .shadow(
                        color: isCompleted ? Color.purple.opacity(0.08) : Color.black.opacity(0.05),
                        radius: 8, y: 3
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        isCompleted ? Color.purple.opacity(0.15) : Color.clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            isCompleted = task.isCompleted
            animateCheck = isCompleted
        }
        .onChange(of: task.isCompleted) { _, newValue in
            isCompleted = newValue
            animateCheck = newValue
        }
    }

    private func toggleTaskCompletion() {
        task.isCompleted.toggle()
        isCompleted = task.isCompleted
        animateCheck = isCompleted
        try? modelContext.save()
        if task.isCompleted {
            NotificationManager.shared.cancelReminder(for: task)
        } else {
            NotificationManager.shared.scheduleReminder(for: task)
        }
        onToggle()
    }
}

#Preview {
    let schema = Schema([TodoTask.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let task = TodoTask(title: "Call Apple Support")
    let _ = {
        container.mainContext.insert(task)
    }()

    return TodoTaskRowView(task: task, onToggle: {}, onTap: {})
        .padding()
        .background(Color(.systemGroupedBackground))
        .modelContainer(container)
}
