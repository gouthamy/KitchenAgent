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
            UserSettings.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Request notification permissions on app launch
        Task {
            try? await NotificationService.shared.requestAuthorization()
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
