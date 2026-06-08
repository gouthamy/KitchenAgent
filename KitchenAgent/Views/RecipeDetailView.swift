//
//  RecipeDetailView.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

struct RecipeDetailView: View {
    let recipe: Recipe

    @State private var isFavorite = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Image
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(height: 250)
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.system(size: 80))
                            .foregroundColor(.green)
                    )
                    .frame(maxWidth: .infinity)

                VStack(alignment: .leading, spacing: 16) {
                    // Title & Stats
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(recipe.name)
                                .font(.title)
                                .fontWeight(.bold)

                            HStack {
                                Label("\(recipe.cookingTime) min", systemImage: "clock")
                                Text("•")
                                Text(recipe.difficulty.rawValue)
                            }
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        }
                        Spacer()
                        Button {
                            isFavorite.toggle()
                        } label: {
                            Image(systemName: isFavorite ? "heart.fill" : "heart")
                                .font(.title2)
                                .foregroundColor(isFavorite ? .red : .secondary)
                        }
                    }

                    Divider()

                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients")
                            .font(.title3)
                            .fontWeight(.bold)

                        ForEach(recipe.ingredients, id: \.self) { ingredient in
                            HStack {
                                Circle()
                                    .fill(Color.green)
                                    .frame(width: 8, height: 8)
                                Text(ingredient)
                                    .font(.body)
                                Spacer()
                            }
                        }
                    }

                    Divider()

                    // Instructions
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions")
                            .font(.title3)
                            .fontWeight(.bold)

                        Text(recipe.instructions)
                            .font(.body)
                            .lineSpacing(6)
                    }

                    // Start Cooking Button
                    Button {
                        // Start cooking action
                    } label: {
                        Label("Start Cooking", systemImage: "play.fill")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            isFavorite = recipe.isFavorite
        }
    }
}

#Preview {
    NavigationStack {
        RecipeDetailView(recipe: Recipe(
            name: "Palak Paneer",
            cookingTime: 20,
            difficulty: .easy,
            ingredients: ["Spinach", "Paneer", "Onion", "Tomato", "Cream"],
            instructions: "1. Blanch spinach\n2. Sauté onions\n3. Add tomatoes\n4. Add spinach and paneer\n5. Add cream"
        ))
    }
}
