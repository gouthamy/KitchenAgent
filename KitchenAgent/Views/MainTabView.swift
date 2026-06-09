//
//  MainTabView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

            InventoryView()
                .tabItem {
                    Label("Inventory", systemImage: "list.bullet.rectangle")
                }
                .tag(1)

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(2)

            FoodTrackingView()
                .tabItem {
                    Label("Track", systemImage: "camera.fill")
                }
                .tag(3)

            MealPlanView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                }
                .tag(4)

            ShoppingListView()
                .tabItem {
                    Label("Shopping", systemImage: "cart.fill")
                }
                .tag(5)

            SettingsView()
                .tabItem {
                    Label("More", systemImage: "ellipsis")
                }
                .tag(6)
        }
        .accentColor(Theme.Colors.primary)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [FridgeItem.self, Recipe.self, ShoppingItem.self, UserSettings.self, MealPlan.self, PlannedMeal.self, FoodLog.self], inMemory: true)
}
