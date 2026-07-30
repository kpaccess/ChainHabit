//
//  AddEditHabitView.swift
//  HabitTracker
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI
import SwiftData

struct AddEditHabitView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var existingHabits: [Habit]
    
    @State private var habitName = ""
    @State private var habitNotes = ""
    @State private var selectedColor: Color = .habitColors[0]
    @State private var selectedFrequency: Habit.Frequency = .daily
    @State private var selectedStartDate = Calendar.current.startOfDay(for: Date())
    @State private var hasEndDate = false
    @State private var selectedEndDate = Calendar.current.startOfDay(for: Date())

    // For custom frequency options
    @State private var frequencyType: FrequencyType = .daily
    @State private var selectedDays: Set<Int> = []
    @State private var everyXDaysInterval: Int = 2

    // Reminder options
    @State private var morningReminderEnabled = false
    @State private var morningReminderTime = Habit.defaultMorningTime
    @State private var eveningReminderEnabled = false
    @State private var eveningReminderTime = Habit.defaultEveningTime
    
    private var isDuplicateName: Bool {
        existingHabits.contains { habit in
            habit.name.lowercased() == habitName.trimmingCharacters(in: .whitespaces).lowercased() &&
            habit.uuid != habitToEdit?.uuid
        }
    }
    
    enum FrequencyType: String, CaseIterable {
        case daily = "Daily"
        case weekly = "Weekly"
        case customDays = "Specific Days"
        case everyXDays = "Every X Days"
        case monthly = "Monthly"
        
        var icon: String {
            switch self {
            case .daily: return "sun.max.fill"
            case .weekly: return "calendar.badge.clock"
            case .customDays: return "calendar"
            case .everyXDays: return "arrow.clockwise"
            case .monthly: return "calendar.circle"
            }
        }
    }
    
    let habitToEdit: Habit?
    
    init(habitToEdit: Habit? = nil, initialName: String? = nil) {
        self.habitToEdit = habitToEdit
        
        if let habit = habitToEdit {
            _habitName = State(initialValue: habit.name)
            _habitNotes = State(initialValue: habit.notes)
            _selectedColor = State(initialValue: habit.color)
            _selectedFrequency = State(initialValue: habit.frequency)
            _selectedStartDate = State(initialValue: Calendar.current.startOfDay(for: habit.creationDate))
            _hasEndDate = State(initialValue: habit.endDate != nil)
            _selectedEndDate = State(initialValue: Calendar.current.startOfDay(for: habit.endDate ?? Date()))
            
            // Set frequency type based on habit frequency
            switch habit.frequency {
            case .daily:
                _frequencyType = State(initialValue: .daily)
            case .weekly:
                _frequencyType = State(initialValue: .weekly)
            case .customDays(let days):
                _frequencyType = State(initialValue: .customDays)
                _selectedDays = State(initialValue: days)
            case .everyXDays(let interval):
                _frequencyType = State(initialValue: .everyXDays)
                _everyXDaysInterval = State(initialValue: interval)
            case .monthly:
                _frequencyType = State(initialValue: .monthly)
            }

            _morningReminderEnabled = State(initialValue: habit.morningReminderEnabled)
            _morningReminderTime = State(initialValue: habit.morningReminderTime)
            _eveningReminderEnabled = State(initialValue: habit.eveningReminderEnabled)
            _eveningReminderTime = State(initialValue: habit.eveningReminderTime)
        } else if let initialName = initialName {
            _habitName = State(initialValue: initialName)
        }
    }
    
    private var nextAppearanceText: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let startDate = calendar.startOfDay(for: selectedStartDate)
        let weekdaySymbols = calendar.weekdaySymbols
        
        for i in 0...7 {
            guard let targetDate = calendar.date(byAdding: .day, value: i, to: today) else { continue }
            if targetDate < startDate { continue }
            let weekday = calendar.component(.weekday, from: targetDate)
            
            let isScheduled: Bool
            switch frequencyType {
            case .daily:
                isScheduled = true
            case .weekly:
                let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
                isScheduled = daysSinceStart >= 0 && daysSinceStart % 7 == 0
            case .customDays:
                isScheduled = selectedDays.contains(weekday)
            case .everyXDays:
                let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: targetDate).day ?? 0
                isScheduled = daysSinceStart >= 0 && daysSinceStart % everyXDaysInterval == 0
            case .monthly:
                isScheduled = calendar.component(.day, from: startDate) == calendar.component(.day, from: targetDate)
            }
            
            if isScheduled {
                if i == 0 { return "Today" }
                if i == 1 { return "Tomorrow" }
                return weekdaySymbols[weekday - 1]
            }
        }
        return "Soon"
    }
    
    private var frequencyIsValid: Bool {
        switch frequencyType {
        case .customDays:
            return !selectedDays.isEmpty
        default:
            return true
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField("Habit Name", text: $habitName)
                            .autocorrectionDisabled()

                        TextField("Notes", text: $habitNotes, axis: .vertical)
                            .lineLimit(3...6)
                        
                        if isDuplicateName {
                            Label("A habit with this name already exists", systemImage: "exclamationmark.triangle.fill")
                                .font(.caption)
                                .foregroundStyle(.red)
                        }
                    }
                } header: {
                    Text("Habit Details")
                }
                
                Section {
                    Picker("Frequency Type", selection: $frequencyType) {
                        ForEach(FrequencyType.allCases, id: \.self) { type in
                            Label(type.rawValue, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Show additional options based on frequency type
                    switch frequencyType {
                    case .daily, .weekly, .monthly:
                        EmptyView()
                        
                    case .customDays:
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Select days of the week")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            WeekdayPicker(selectedDays: $selectedDays)
                        }
                        
                    case .everyXDays:
                        HStack {
                            Text("Repeat every")
                            
                            Stepper("\(everyXDaysInterval)", value: $everyXDaysInterval, in: 2...30)
                                .labelsHidden()
                            
                            Text(everyXDaysInterval == 1 ? "day" : "days")
                        }
                    }
                    
                    if frequencyIsValid {
                        HStack {
                            Label("Will show in list:", systemImage: "calendar.badge.clock")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(nextAppearanceText)
                                .font(.subheadline.bold())
                                .foregroundStyle(.purple)
                        }
                        .padding(.vertical, 4)
                    }
                } header: {
                    Text("Frequency")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        frequencyFooterText
                        Text("Habits only appear in your main list on their scheduled days.")
                    }
                }
                
                Section("Color") {
                    ColorPickerGrid(selectedColor: $selectedColor)
                }

                Section {
                    DatePicker(
                        "Start Date",
                        selection: $selectedStartDate,
                        displayedComponents: .date
                    )

                    Toggle("Set End Date", isOn: $hasEndDate.animation())

                    if hasEndDate {
                        DatePicker(
                            "End Date",
                            selection: $selectedEndDate,
                            in: Calendar.current.startOfDay(for: selectedStartDate)...,
                            displayedComponents: .date
                        )
                    }
                } header: {
                    Text("Duration")
                } footer: {
                    Text("New habits start today by default, but you can choose any start date. If set, the habit will stop appearing after the end date.")
                }

                Section {
                    Toggle("Morning Reminder", isOn: $morningReminderEnabled)
                    if morningReminderEnabled {
                        DatePicker("Time", selection: $morningReminderTime, displayedComponents: .hourAndMinute)
                    }
                    Toggle("Evening Reminder", isOn: $eveningReminderEnabled)
                    if eveningReminderEnabled {
                        DatePicker("Time", selection: $eveningReminderTime, displayedComponents: .hourAndMinute)
                    }
                } header: {
                    Text("Reminders")
                } footer: {
                    Text("Evening reminder only fires if the habit isn't completed yet.")
                }
            }
            .navigationTitle(habitToEdit == nil ? "New Habit" : "Edit Habit")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: selectedStartDate) { _, newValue in
                let normalizedStartDate = Calendar.current.startOfDay(for: newValue)
                if selectedStartDate != normalizedStartDate {
                    selectedStartDate = normalizedStartDate
                }

                if hasEndDate && selectedEndDate < normalizedStartDate {
                    selectedEndDate = normalizedStartDate
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
                        saveHabit()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private var frequencyFooterText: Text {
        switch frequencyType {
        case .daily:
            return Text("Track this habit every day")
        case .weekly:
            return Text("Track this habit once per week")
        case .customDays:
            if selectedDays.isEmpty {
                return Text("Select at least one day")
            } else {
                return Text("Track on selected days only")
            }
        case .everyXDays:
            return Text("Track every \(everyXDaysInterval) days")
        case .monthly:
            return Text("Track this habit once per month")
        }
    }
    
    private var canSave: Bool {
        let nameValid = !habitName.trimmingCharacters(in: .whitespaces).isEmpty
        return nameValid && frequencyIsValid && !isDuplicateName
    }
    
    private func saveHabit() {
        let startDate = Calendar.current.startOfDay(for: selectedStartDate)
        let trimmedName = habitName.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = habitNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        let endDate = hasEndDate ? Calendar.current.startOfDay(for: selectedEndDate) : nil
        
        // Create frequency based on type
        let frequency: Habit.Frequency
        switch frequencyType {
        case .daily:
            frequency = .daily
        case .weekly:
            frequency = .weekly
        case .customDays:
            frequency = .customDays(selectedDays)
        case .everyXDays:
            frequency = .everyXDays(everyXDaysInterval)
        case .monthly:
            frequency = .monthly
        }
        
        if let habit = habitToEdit {
            habit.name = trimmedName
            habit.notes = trimmedNotes
            habit.colorHex = selectedColor.toHex() ?? "3498DB"
            habit.creationDate = startDate
            habit.frequency = frequency
            habit.endDate = endDate
            habit.morningReminderEnabled = morningReminderEnabled
            habit.morningReminderTime = morningReminderTime
            habit.eveningReminderEnabled = eveningReminderEnabled
            habit.eveningReminderTime = eveningReminderTime
            try? modelContext.save()
            NotificationManager.shared.scheduleNotifications(for: habit)
        } else {
            let newHabit = Habit(
                name: trimmedName,
                colorHex: selectedColor.toHex() ?? "3498DB",
                creationDate: startDate,
                notes: trimmedNotes,
                frequency: frequency,
                endDate: endDate,
                morningReminderEnabled: morningReminderEnabled,
                morningReminderTime: morningReminderTime,
                eveningReminderEnabled: eveningReminderEnabled,
                eveningReminderTime: eveningReminderTime
            )
            modelContext.insert(newHabit)
            try? modelContext.save()
            NotificationManager.shared.scheduleNotifications(for: newHabit)
        }

        dismiss()
    }
}

struct ColorPickerGrid: View {
    @Binding var selectedColor: Color
    
    let columns = [
        GridItem(.adaptive(minimum: 50))
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(Color.habitColors, id: \.self) { color in
                Button {
                    selectedColor = color
                } label: {
                    ZStack {
                        Circle()
                            .fill(color)
                            .frame(width: 50, height: 50)
                        
                        if selectedColor == color {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.white)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 8)
    }
}

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<Int>
    
    private let weekdays: [(index: Int, name: String)] = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        // Get short weekday symbols (Sun, Mon, Tue, etc.)
        let symbols = formatter.shortWeekdaySymbols!
        return symbols.enumerated().map { (index, name) in
            (index + 1, name) // Calendar.current uses 1-based indexing (1 = Sunday)
        }
    }()
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(weekdays, id: \.index) { weekday in
                Button {
                    toggleDay(weekday.index)
                } label: {
                    Text(weekday.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(selectedDays.contains(weekday.index) ? Color.accentColor : Color(.systemGray5))
                        )
                        .foregroundStyle(selectedDays.contains(weekday.index) ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private func toggleDay(_ day: Int) {
        if selectedDays.contains(day) {
            selectedDays.remove(day)
        } else {
            selectedDays.insert(day)
        }
    }
}

#Preview("Add Habit") {
    AddEditHabitView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}

#Preview("Edit Habit") {
    let schema = Schema([Habit.self, HabitLog.self])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])
    
    let habit = Habit(name: "Morning Meditation", colorHex: "9B59B6", frequency: .daily)
    container.mainContext.insert(habit)
    
    return AddEditHabitView(habitToEdit: habit)
        .modelContainer(container)
}
