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

    @State private var searchText = ""

    private var availableIngredients: [String] {
        items.filter { !$0.isExpired }.map { $0.name }
    }

    private var suggestedRecipes: [Recipe] {
        RecipeService.shared.getSuggestedRecipes(basedOn: availableIngredients)
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

#Preview {
    RecipesView()
        .modelContainer(for: [FridgeItem.self, Recipe.self], inMemory: true)
}
