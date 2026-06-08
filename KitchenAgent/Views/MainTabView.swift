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

            ShoppingListView()
                .tabItem {
                    Label("Shopping", systemImage: "cart.fill")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(4)
        }
        .accentColor(.green)
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [FridgeItem.self, Recipe.self, ShoppingItem.self, UserSettings.self], inMemory: true)
}
