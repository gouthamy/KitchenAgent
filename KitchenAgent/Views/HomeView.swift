//
//  HomeView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \FridgeItem.expiryDate) private var items: [FridgeItem]
    @Query private var settings: [UserSettings]
    @Query private var recipes: [Recipe]

    @State private var showingAddItem = false

    private var userSettings: UserSettings {
        if let existing = settings.first {
            return existing
        }
        // Create and insert default settings if none exist
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        try? modelContext.save()
        return newSettings
    }

    private var expiringSoonItems: [FridgeItem] {
        items.filter { $0.isExpiringSoon }
    }

    private var expiredItems: [FridgeItem] {
        items.filter { $0.isExpired }
    }

    private var suggestedRecipes: [Recipe] {
        let ingredientNames = items.filter { !$0.isExpired }.map { $0.name }
        return RecipeService.shared.getSuggestedRecipes(basedOn: ingredientNames).prefix(3).map { $0 }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Hello \(userSettings.userName) 👋")
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("Here's what's in your fridge today")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            // Notification action
                        } label: {
                            Image(systemName: "bell")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                    }
                    .padding(.horizontal)

                    // Expiring Soon Section
                    if !expiringSoonItems.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                Text("Expiring Soon")
                                    .font(.headline)
                                Spacer()
                                NavigationLink {
                                    ExpiryRemindersView()
                                } label: {
                                    Text("View All")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                            }
                            .padding(.horizontal)

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(expiringSoonItems.prefix(5)) { item in
                                        ExpiryItemCard(item: item)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }

                    // You Can Cook Section
                    if !suggestedRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "lightbulb.fill")
                                    .foregroundColor(.yellow)
                                Text("You can cook")
                                    .font(.headline)
                                Text("Based on items expiring soon")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal)

                            ForEach(suggestedRecipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    RecipeCard(recipe: recipe)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                    }
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        // Menu action
                    } label: {
                        Image(systemName: "line.3.horizontal")
                    }
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddItemView()
            }
        }
    }
}

struct ExpiryItemCard: View {
    let item: FridgeItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let imageData = item.imageData, let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Circle()
                    .fill(item.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Text(item.emoji)
                            .font(.system(size: 35))
                    )
            }

            Text(item.name)
                .font(.subheadline)
                .fontWeight(.medium)

            if let days = item.daysUntilExpiry {
                Text("\(days) \(days == 1 ? "day" : "days") left")
                    .font(.caption)
                    .foregroundColor(days <= 1 ? .red : .orange)
            }
        }
        .frame(width: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct RecipeCard: View {
    let recipe: Recipe

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 60, height: 60)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundColor(.green)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Text("\(recipe.cookingTime) min")
                    Text("•")
                    Text(recipe.difficulty.rawValue)
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }

            Spacer()

            Image(systemName: "plus.circle.fill")
                .font(.title2)
                .foregroundColor(.green)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [FridgeItem.self, UserSettings.self, Recipe.self], inMemory: true)
}
