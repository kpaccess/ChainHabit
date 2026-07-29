//
//  AddEditTodoTaskView.swift
//  ChainHabit
//
//  Created by Krishna pradhan on 2026-05-28.
//

import SwiftUI
import SwiftData

struct AddEditTodoTaskView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Query private var existingTasks: [TodoTask]

    @State private var taskTitle = ""
    @State private var taskNotes = ""
    @State private var dueDate = TodoTask.defaultDueDate()
    @State private var reminderEnabled = false
    @State private var reminderDate = TodoTask.defaultReminderDate(for: TodoTask.defaultDueDate())

    let taskToEdit: TodoTask?
    let initialDate: Date
    
    private var isDuplicateTask: Bool {
        let calendar = Calendar.current
        return existingTasks.contains { task in
            task.title.lowercased() == taskTitle.trimmingCharacters(in: .whitespaces).lowercased() &&
            calendar.isDate(task.dueDate, inSameDayAs: dueDate) &&
            task.uuid != taskToEdit?.uuid
        }
    }

    init(taskToEdit: TodoTask? = nil, initialDate: Date = Date()) {
        self.taskToEdit = taskToEdit
        self.initialDate = initialDate
        
        if let task = taskToEdit {
            _taskTitle = State(initialValue: task.title)
            _taskNotes = State(initialValue: task.notes)
            _dueDate = State(initialValue: task.dueDate)
            _reminderEnabled = State(initialValue: task.reminderEnabled)
            _reminderDate = State(initialValue: task.reminderDate)
        } else {
            let defaultDueDate = TodoTask.defaultDueDate(on: initialDate)
            _dueDate = State(initialValue: defaultDueDate)
            _reminderDate = State(initialValue: TodoTask.defaultReminderDate(for: defaultDueDate))
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task Title", text: $taskTitle)
                        .autocorrectionDisabled()

                    TextField("Notes", text: $taskNotes, axis: .vertical)
                        .lineLimit(3...6)
                    
                    if isDuplicateTask {
                        Text("This task is already scheduled for this day")
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                } header: {
                    Text("Task Details")
                }

                Section {
                    DatePicker("Due", selection: $dueDate, displayedComponents: [.date, .hourAndMinute])
                } header: {
                    Text("Schedule")
                } footer: {
                    Text("This task will appear on its scheduled day, with the time you choose.")
                }

                Section {
                    Toggle("Reminder", isOn: $reminderEnabled)
                    if reminderEnabled {
                        DatePicker("Remind Me", selection: $reminderDate, in: ...dueDate, displayedComponents: [.date, .hourAndMinute])
                    }
                } header: {
                    Text("Reminder")
                } footer: {
                    Text("Choose when you want a reminder before the task is due.")
                }

                if taskToEdit != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteTask()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Task")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(taskToEdit == nil ? "New Task" : "Edit Task")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: dueDate) { _, newDueDate in
                if reminderDate > newDueDate {
                    reminderDate = newDueDate
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(taskTitle.trimmingCharacters(in: .whitespaces).isEmpty || isDuplicateTask)
                }
            }
        }
    }

    private func saveTask() {
        let trimmedTitle = taskTitle.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = taskNotes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let task = taskToEdit {
            task.title = trimmedTitle
            task.notes = trimmedNotes
            task.dueDate = dueDate
            task.reminderEnabled = reminderEnabled
            task.reminderDate = reminderDate
            try? modelContext.save()
            NotificationManager.shared.scheduleReminder(for: task)
        } else {
            let newTask = TodoTask(
                title: trimmedTitle,
                notes: trimmedNotes,
                dueDate: dueDate,
                reminderEnabled: reminderEnabled,
                reminderDate: reminderDate
            )
            modelContext.insert(newTask)
            try? modelContext.save()
            NotificationManager.shared.scheduleReminder(for: newTask)
        }

        dismiss()
    }

    private func deleteTask() {
        if let task = taskToEdit {
            NotificationManager.shared.cancelReminder(for: task)
            modelContext.delete(task)
            try? modelContext.save()
        }
        dismiss()
    }
}

#Preview {
    AddEditTodoTaskView()
        .modelContainer(for: [TodoTask.self], inMemory: true)
}
