//
//  KitchenAgentApp.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

@main
struct KitchenAgentApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            FridgeItem.self,
            Recipe.self,
            ShoppingItem.self,
            UserSettings.self,
            MealPlan.self,
            PlannedMeal.self,
            FoodLog.self
        ])

        // Enable automatic migration for schema changes
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // If migration fails, try to recreate the container
            print("⚠️ ModelContainer creation failed: \(error)")
            print("🔄 Attempting to reset data store...")

            // Clear the data store and try again
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)

            do {
                let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                print("✅ Successfully created fresh ModelContainer")
                return container
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()

    init() {
        // Request notification permissions on app launch
        Task {
            _ = try? await NotificationService.shared.requestAuthorization()
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .onAppear {
                    print("✅ App loaded successfully")
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
