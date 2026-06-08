//
//  RecipeService.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation

class RecipeService {
    static let shared = RecipeService()

    private init() {}

    func getSuggestedRecipes(basedOn ingredients: [String]) -> [Recipe] {
        let allRecipes = getDefaultRecipes()

        // Filter recipes that can be made with available ingredients
        return allRecipes.filter { recipe in
            let matchingIngredients = recipe.ingredients.filter { recipeIngredient in
                ingredients.contains { ingredient in
                    recipeIngredient.lowercased().contains(ingredient.lowercased())
                }
            }
            return matchingIngredients.count >= 2
        }
    }

    func getDefaultRecipes() -> [Recipe] {
        return [
            Recipe(
                name: "Palak Paneer",
                imageName: "palak_paneer",
                cookingTime: 20,
                difficulty: .easy,
                ingredients: ["Spinach", "Paneer", "Onion", "Tomato", "Ginger", "Garlic", "Cream"],
                instructions: "1. Blanch spinach and blend to paste\n2. Sauté onions, ginger, garlic\n3. Add tomatoes and spices\n4. Add spinach paste and paneer\n5. Simmer for 10 minutes\n6. Add cream and serve hot",
                isFavorite: false
            ),
            Recipe(
                name: "Tomato Chutney",
                imageName: "tomato_chutney",
                cookingTime: 15,
                difficulty: .easy,
                ingredients: ["Tomato", "Onion", "Green Chili", "Curry Leaves", "Mustard Seeds"],
                instructions: "1. Roast tomatoes and onions\n2. Blend with green chili\n3. Temper with mustard seeds and curry leaves\n4. Mix and serve",
                isFavorite: false
            ),
            Recipe(
                name: "Veg Stir Fry",
                imageName: "veg_stir_fry",
                cookingTime: 20,
                difficulty: .medium,
                ingredients: ["Capsicum", "Carrot", "Beans", "Onion", "Soy Sauce", "Garlic"],
                instructions: "1. Cut all vegetables into strips\n2. Heat oil in wok\n3. Stir fry vegetables on high heat\n4. Add soy sauce and seasonings\n5. Serve hot",
                isFavorite: false
            ),
            Recipe(
                name: "Carrot Soup",
                imageName: "carrot_soup",
                cookingTime: 25,
                difficulty: .easy,
                ingredients: ["Carrot", "Onion", "Garlic", "Vegetable Stock", "Cream"],
                instructions: "1. Sauté onions and garlic\n2. Add chopped carrots and stock\n3. Simmer until carrots are soft\n4. Blend until smooth\n5. Add cream and season\n6. Serve hot",
                isFavorite: false
            ),
            Recipe(
                name: "Potato Curry",
                imageName: "potato_curry",
                cookingTime: 30,
                difficulty: .easy,
                ingredients: ["Potato", "Onion", "Tomato", "Turmeric", "Coriander"],
                instructions: "1. Boil potatoes and cube them\n2. Sauté onions until golden\n3. Add tomatoes and spices\n4. Add potatoes and water\n5. Simmer until gravy thickens\n6. Garnish with coriander",
                isFavorite: false
            ),
            Recipe(
                name: "Green Salad",
                imageName: "green_salad",
                cookingTime: 10,
                difficulty: .easy,
                ingredients: ["Spinach", "Cucumber", "Tomato", "Onion", "Lemon", "Olive Oil"],
                instructions: "1. Wash and chop all vegetables\n2. Mix in a bowl\n3. Add lemon juice and olive oil\n4. Season with salt and pepper\n5. Toss and serve fresh",
                isFavorite: false
            )
        ]
    }
}
