//
//  RecipesView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI
import SwiftData

struct RecipesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [FridgeItem]
    @Query private var recipes: [Recipe]
    @Query private var settings: [UserSettings]

    @State private var searchText = ""
    @State private var aiRecipes: [AIRecipeSuggestion] = []
    @State private var isLoadingAI = false
    @State private var aiError: String? = nil

    private var userSettings: UserSettings {
        if let existing = settings.first {
            return existing
        }
        let newSettings = UserSettings()
        modelContext.insert(newSettings)
        try? modelContext.save()
        return newSettings
    }

    private var availableIngredients: [String] {
        items.filter { !$0.isExpired }.map { $0.name }
    }

    private var expiringIngredients: [String] {
        items.filter { $0.isExpiringSoon && !$0.isExpired }.map { $0.name }
    }

    private var suggestedRecipes: [Recipe] {
        RecipeService.shared.getSuggestedRecipes(basedOn: availableIngredients)
    }

    private var hasAPIKey: Bool {
        if let apiKey = UserDefaults.standard.string(forKey: "chatgpt_api_key"), !apiKey.isEmpty {
            return true
        }
        return false
    }

    private var filteredRecipes: [Recipe] {
        if searchText.isEmpty {
            return RecipeService.shared.getDefaultRecipes()
        } else {
            return RecipeService.shared.getDefaultRecipes().filter {
                $0.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Search Bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search recipes", text: $searchText)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // SECTION 0: ChatGPT AI Suggestions (if API key configured)
                    if hasAPIKey && !availableIngredients.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header with Generate button
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                    .font(.title3)
                                Text("AI Recipe Suggestions")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                Spacer()
                                Button {
                                    loadAIRecipes()
                                } label: {
                                    HStack(spacing: 4) {
                                        if isLoadingAI {
                                            ProgressView()
                                                .scaleEffect(0.8)
                                        } else {
                                            Image(systemName: "wand.and.stars")
                                            Text("Generate")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.purple.opacity(0.2))
                                    .foregroundColor(.purple)
                                    .cornerRadius(20)
                                }
                                .disabled(isLoadingAI)
                            }
                            .padding(.horizontal)

                            // Cuisine preference display
                            HStack(spacing: 8) {
                                Text("Cuisine:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(userSettings.preferredCuisine)
                                    .font(.caption)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 4)
                                    .background(Color.purple.opacity(0.2))
                                    .foregroundColor(.purple)
                                    .cornerRadius(12)

                                if !userSettings.dietaryPreferences.isEmpty {
                                    ForEach(userSettings.dietaryPreferences.prefix(2), id: \.self) { pref in
                                        Text(pref)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(Color.green.opacity(0.2))
                                            .foregroundColor(.green)
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(.horizontal)

                            // AI Recipes
                            if isLoadingAI {
                                HStack {
                                    Spacer()
                                    VStack(spacing: 12) {
                                        ProgressView()
                                            .scaleEffect(1.2)
                                        Text("Generating personalized recipes...")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 40)
                                    Spacer()
                                }
                            } else if let error = aiError {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.orange)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                    Button("Try Again") {
                                        loadAIRecipes()
                                    }
                                    .font(.subheadline)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(Color.purple.opacity(0.2))
                                    .foregroundColor(.purple)
                                    .cornerRadius(20)
                                }
                                .padding(.vertical, 20)
                                .padding(.horizontal)
                            } else if !aiRecipes.isEmpty {
                                ForEach(aiRecipes) { recipe in
                                    NavigationLink {
                                        AIRecipeDetailView(recipe: recipe)
                                    } label: {
                                        AIRecipeCard(recipe: recipe, availableIngredients: availableIngredients)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Image(systemName: "wand.and.stars")
                                        .font(.system(size: 40))
                                        .foregroundColor(.purple)
                                    Text("Tap 'Generate' to get AI-powered recipes")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    Text("Based on your \(userSettings.preferredCuisine) preferences")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 20)
                            }
                        }
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal, 8)
                    }

                    // SECTION 1: Recipe Suggestions (Based on Your Ingredients) - PROMINENT
                    if !suggestedRecipes.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            // Header
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Based on your ingredients")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                    Image(systemName: "sparkles")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                }
                                .padding(.horizontal)

                                // Available Ingredients Pills
                                if !availableIngredients.isEmpty {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(availableIngredients.prefix(10), id: \.self) { ingredient in
                                                Text(ingredient)
                                                    .font(.caption)
                                                    .padding(.horizontal, 12)
                                                    .padding(.vertical, 6)
                                                    .background(Color.green.opacity(0.2))
                                                    .foregroundColor(.green)
                                                    .cornerRadius(16)
                                            }
                                        }
                                        .padding(.horizontal)
                                    }
                                }
                            }

                            // Suggested Recipe Cards (Prominent)
                            ForEach(suggestedRecipes) { recipe in
                                NavigationLink {
                                    RecipeDetailView(recipe: recipe)
                                } label: {
                                    SuggestedRecipeCard(recipe: recipe, availableIngredients: availableIngredients)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.05))
                        .cornerRadius(16)
                        .padding(.horizontal, 8)
                    } else if !availableIngredients.isEmpty {
                        // Show message when no recipes match
                        VStack(spacing: 12) {
                            Image(systemName: "fork.knife.circle")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            Text("No recipes found")
                                .font(.headline)
                            Text("Add more ingredients to get recipe suggestions!")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }

                    // SECTION 2: All Recipes
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("All Recipes")
                                .font(.title3)
                                .fontWeight(.bold)
                            Spacer()
                            Text("\(filteredRecipes.count) recipes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        // All Recipe Cards (Compact)
                        ForEach(filteredRecipes) { recipe in
                            NavigationLink {
                                RecipeDetailView(recipe: recipe)
                            } label: {
                                CompactRecipeCard(recipe: recipe, availableIngredients: availableIngredients)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Recipes")
        }
    }

    private func loadAIRecipes() {
        isLoadingAI = true
        aiError = nil

        Task {
            do {
                let recipes = try await ChatGPTRecipeService.shared.generateRecipeSuggestions(
                    ingredients: availableIngredients,
                    cuisine: userSettings.preferredCuisine,
                    dietaryPreferences: userSettings.dietaryPreferences,
                    expiringItems: expiringIngredients
                )

                await MainActor.run {
                    self.aiRecipes = recipes
                    self.isLoadingAI = false
                }
            } catch {
                await MainActor.run {
                    self.aiError = error.localizedDescription
                    self.isLoadingAI = false
                }
            }
        }
    }
}

// MARK: - Suggested Recipe Card (Prominent with green highlight)
struct SuggestedRecipeCard: View {
    let recipe: Recipe
    let availableIngredients: [String]

    private var matchingIngredientsCount: Int {
        recipe.ingredients.filter { ingredient in
            availableIngredients.contains { available in
                ingredient.localizedCaseInsensitiveContains(available)
            }
        }.count
    }

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Circle()
                .fill(Color.green.opacity(0.2))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 30))
                        .foregroundColor(.green)
                )

            // Details
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.name)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack(spacing: 12) {
                    Label("\(recipe.cookingTime) min", systemImage: "clock")
                        .font(.caption)
                    Text("•")
                    Text(recipe.difficulty.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                // Matching ingredients badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("\(matchingIngredientsCount) ingredients available")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.green)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Compact Recipe Card (For "All Recipes" section)
struct CompactRecipeCard: View {
    let recipe: Recipe
    let availableIngredients: [String]

    private var matchingIngredientsCount: Int {
        recipe.ingredients.filter { ingredient in
            availableIngredients.contains { available in
                ingredient.localizedCaseInsensitiveContains(available)
            }
        }.count
    }

    var body: some View {
        HStack(spacing: 12) {
            // Smaller Icon
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: "fork.knife")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                )

            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)

                HStack(spacing: 8) {
                    Text("\(recipe.cookingTime) min")
                        .font(.caption)
                    Text("•")
                    Text(recipe.difficulty.rawValue)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                // Show matching if any
                if matchingIngredientsCount > 0 {
                    Text("\(matchingIngredientsCount) ingredients available")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }

            Spacer()

            // Favorite button
            Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                .foregroundColor(recipe.isFavorite ? .red : .secondary)
                .font(.title3)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - AI Recipe Card
struct AIRecipeCard: View {
    let recipe: AIRecipeSuggestion
    let availableIngredients: [String]

    var body: some View {
        HStack(spacing: 16) {
            // Icon with purple theme
            Circle()
                .fill(Color.purple.opacity(0.2))
                .frame(width: 70, height: 70)
                .overlay(
                    Image(systemName: "sparkles")
                        .font(.system(size: 30))
                        .foregroundColor(.purple)
                )

            // Details
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(recipe.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "sparkles")
                        .font(.caption)
                        .foregroundColor(.purple)
                }

                HStack(spacing: 12) {
                    Label("\(recipe.cookingTime) min", systemImage: "clock")
                        .font(.caption)
                    Text("•")
                    Text(recipe.difficulty)
                        .font(.caption)
                }
                .foregroundColor(.secondary)

                // Matching ingredients badge
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption)
                    Text("\(recipe.matchingIngredientsCount) ingredients available")
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(.purple)
            }

            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.purple.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - AI Recipe Detail View
struct AIRecipeDetailView: View {
    let recipe: AIRecipeSuggestion

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header with icon
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.purple.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundColor(.purple)
                        )

                    Text(recipe.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)

                    HStack(spacing: 20) {
                        Label("\(recipe.cookingTime) min", systemImage: "clock")
                        Text("•")
                        Label(recipe.difficulty, systemImage: "chart.bar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical)

                Divider()

                // Ingredients
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "list.bullet")
                            .foregroundColor(.purple)
                        Text("Ingredients")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    ForEach(recipe.ingredients, id: \.self) { ingredient in
                        HStack(spacing: 12) {
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 8, height: 8)
                            Text(ingredient)
                                .font(.body)
                        }
                    }
                }

                Divider()

                // Instructions
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "book")
                            .foregroundColor(.purple)
                        Text("Instructions")
                            .font(.title3)
                            .fontWeight(.bold)
                    }

                    ForEach(Array(recipe.instructions.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(Color.purple.opacity(0.2))
                                    .frame(width: 28, height: 28)
                                Text("\(index + 1)")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                            }

                            Text(step)
                                .font(.body)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }

                // AI Badge
                HStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "sparkles")
                            .font(.caption)
                        Text("Generated by ChatGPT")
                            .font(.caption)
                    }
                    .foregroundColor(.purple)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    Spacer()
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    RecipesView()
        .modelContainer(for: [FridgeItem.self, Recipe.self, UserSettings.self], inMemory: true)
}
