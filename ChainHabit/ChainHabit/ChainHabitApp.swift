//
//  ChainHabitApp.swift
//  ChainHabit
//
//  Created by Krishna pradhan on 2026-05-15.
//

import SwiftUI
import SwiftData

@main
struct ChainHabitApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema(versionedSchema: ChainHabitSchemaV3.self)
        let modelConfiguration = ModelConfiguration()

        do {
            let container = try ModelContainer(
                for: schema,
                migrationPlan: ChainHabitMigrationPlan.self,
                configurations: [modelConfiguration]
            )
            try validateContainer(container)
            return container
        } catch {
            // Log the error for debugging
            print("❌ Failed to create ModelContainer: \(error)")
            print("Error details: \(error.localizedDescription)")

            // Try to create an in-memory container as fallback
            do {
                print("⚠️ Persistent store is unavailable. Falling back to in-memory mode to avoid modifying on-device data.")
                let fallbackConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                let fallbackContainer = try ModelContainer(for: schema, configurations: [fallbackConfiguration])
                print("✅ Fallback container created successfully")
                return fallbackContainer
            } catch {
                // If even the fallback fails, we have no choice but to crash
                fatalError("Could not create ModelContainer (including fallback): \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

private func validateContainer(_ container: ModelContainer) throws {
    let context = ModelContext(container)
    var habitsDescriptor = FetchDescriptor<Habit>()
    habitsDescriptor.fetchLimit = 1

    var tasksDescriptor = FetchDescriptor<TodoTask>()
    tasksDescriptor.fetchLimit = 1

    _ = try context.fetch(habitsDescriptor)
    _ = try context.fetch(tasksDescriptor)
}
