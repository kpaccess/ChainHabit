//
//  ContentView.swift
//  HabitTracker
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        HabitListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Habit.self, HabitLog.self], inMemory: true)
}
