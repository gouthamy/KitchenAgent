//
//  ShoppingListGeneratorTests.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//
//  This file contains test helpers and examples for ShoppingListGenerator
//

import Foundation

// MARK: - Test Helpers

extension ShoppingListGenerator {
    /// Create a sample meal plan for testing
    static func createSampleMealPlan() -> MealPlan {
        let breakfast = PlannedMeal(
            date: Calendar.current.date(byAdding: .hour, value: 1, to: Date())!,
            mealType: .breakfast,
            recipeName: "Oatmeal with Berries",
            recipeInstructions: "Cook oats with milk, top with berries",
            ingredients: [
                "1 cup oats",
                "1 cup milk",
                "1/2 cup blueberries",
                "1/2 cup strawberries",
                "1 tbsp honey"
            ],
            cookingTime: 15,
            prepTime: 30
        )

        let lunch = PlannedMeal(
            date: Calendar.current.date(byAdding: .hour, value: 5, to: Date())!,
            mealType: .lunch,
            recipeName: "Chicken Salad",
            recipeInstructions: "Grill chicken, toss with vegetables",
            ingredients: [
                "1 chicken breast",
                "2 cups lettuce",
                "1 tomato",
                "1 cucumber",
                "1/2 onion",
                "2 tbsp olive oil"
            ],
            cookingTime: 25,
            prepTime: 30
        )

        let dinner = PlannedMeal(
            date: Calendar.current.date(byAdding: .hour, value: 10, to: Date())!,
            mealType: .dinner,
            recipeName: "Salmon with Vegetables",
            recipeInstructions: "Bake salmon with roasted vegetables",
            ingredients: [
                "1 salmon fillet",
                "2 cups broccoli",
                "1 bell pepper",
                "1 onion",
                "2 tbsp olive oil",
                "salt",
                "pepper"
            ],
            cookingTime: 30,
            prepTime: 30
        )

        return MealPlan(
            name: "Sample Week Plan",
            goal: .healthyEating,
            startDate: Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date())!,
            dailyCalorieTarget: 2000,
            dailyProteinTarget: 150,
            dailyCarbsTarget: 200,
            dailyFatTarget: 65,
            meals: [breakfast, lunch, dinner]
        )
    }

    /// Create sample inventory items
    static func createSampleInventory() -> [FridgeItem] {
        return [
            FridgeItem(
                name: "Milk",
                quantity: 1,
                unit: "L",
                purchaseDate: Date(),
                expiryDate: Calendar.current.date(byAdding: .day, value: 5, to: Date()),
                location: .fridge,
                category: .dairy
            ),
            FridgeItem(
                name: "Onion",
                quantity: 2,
                unit: "whole",
                purchaseDate: Date(),
                expiryDate: Calendar.current.date(byAdding: .day, value: 14, to: Date()),
                location: .pantry,
                category: .vegetable
            ),
            FridgeItem(
                name: "Salt",
                quantity: 1,
                unit: "container",
                purchaseDate: Date(),
                location: .pantry,
                category: .spice
            )
        ]
    }

    /// Print shopping list for debugging
    static func printShoppingList(_ list: CategorizedShoppingList) {
        print("\n📋 Shopping List Summary")
        print("═══════════════════════════════")
        print("Total Items: \(list.totalItemCount)")
        print("Categories: \(list.allCategories.count)")
        print("")

        for category in list.allCategories {
            let items = list.items(for: category)
            print("\(category.icon) \(category.rawValue) (\(items.count) items)")
            print("───────────────────────────────")
            for item in items {
                print("  • \(item.name) (×\(item.quantity))")
            }
            print("")
        }
    }
}

// MARK: - Usage Examples

/// Example 1: Basic Shopping List Generation
func exampleBasicGeneration() {
    print("Example 1: Basic Shopping List Generation")
    print("==========================================\n")

    let mealPlan = ShoppingListGenerator.createSampleMealPlan()
    let inventory: [FridgeItem] = [] // Empty inventory

    let shoppingList = ShoppingListGenerator.shared.generateShoppingList(
        from: mealPlan,
        inventory: inventory
    )

    ShoppingListGenerator.printShoppingList(shoppingList)

    // Expected output:
    // - All ingredients from all meals
    // - Onions: 2 (appears in lunch and dinner)
    // - Olive oil: 2 (appears in lunch and dinner)
    // - Categorized by type
}

/// Example 2: Shopping List with Inventory Deduction
func exampleWithInventoryDeduction() {
    print("Example 2: Shopping List with Inventory Deduction")
    print("==================================================\n")

    let mealPlan = ShoppingListGenerator.createSampleMealPlan()
    let inventory = ShoppingListGenerator.createSampleInventory()

    print("Current Inventory:")
    for item in inventory {
        print("  • \(item.name) (\(item.quantity) \(item.unit))")
    }
    print("")

    let shoppingList = ShoppingListGenerator.shared.generateShoppingList(
        from: mealPlan,
        inventory: inventory
    )

    ShoppingListGenerator.printShoppingList(shoppingList)

    // Expected output:
    // - Milk: NOT in list (already in inventory)
    // - Onion: 1 (need 2, have 1)
    // - Salt: NOT in list (already in inventory)
}

/// Example 3: Convert to Shopping Items for Persistence
func exampleConvertToShoppingItems() {
    print("Example 3: Convert to Shopping Items")
    print("====================================\n")

    let mealPlan = ShoppingListGenerator.createSampleMealPlan()
    let inventory = ShoppingListGenerator.createSampleInventory()

    let shoppingList = ShoppingListGenerator.shared.generateShoppingList(
        from: mealPlan,
        inventory: inventory
    )

    let shoppingItems = ShoppingListGenerator.shared.convertToShoppingItems(shoppingList)

    print("Generated \(shoppingItems.count) shopping items for persistence:")
    for item in shoppingItems.prefix(5) {
        print("  • \(item.name) - Quantity: \(item.quantity)")
    }

    // These items can now be inserted into SwiftData:
    // for item in shoppingItems {
    //     modelContext.insert(item)
    // }
    // try modelContext.save()
}

/// Example 4: Check for Empty Shopping List
func exampleEmptyList() {
    print("Example 4: Empty Shopping List Check")
    print("====================================\n")

    // Create a simple meal plan
    let simpleMeal = PlannedMeal(
        date: Date(),
        mealType: .breakfast,
        recipeName: "Toast with Butter",
        recipeInstructions: "Toast bread, spread butter",
        ingredients: ["bread", "butter"],
        cookingTime: 5,
        prepTime: 5
    )

    let mealPlan = MealPlan(
        name: "Simple Plan",
        goal: .healthyEating,
        startDate: Date(),
        endDate: Date(),
        dailyCalorieTarget: 2000,
        dailyProteinTarget: 150,
        dailyCarbsTarget: 200,
        dailyFatTarget: 65,
        meals: [simpleMeal]
    )

    // Create inventory with all needed items
    let inventory = [
        FridgeItem(
            name: "Bread",
            quantity: 1,
            unit: "loaf",
            purchaseDate: Date(),
            location: .pantry,
            category: .grain
        ),
        FridgeItem(
            name: "Butter",
            quantity: 1,
            unit: "stick",
            purchaseDate: Date(),
            location: .fridge,
            category: .dairy
        )
    ]

    let shoppingList = ShoppingListGenerator.shared.generateShoppingList(
        from: mealPlan,
        inventory: inventory
    )

    if shoppingList.isEmpty {
        print("✅ All ingredients are already in inventory!")
        print("No shopping needed!")
    } else {
        print("Shopping list has \(shoppingList.totalItemCount) items")
    }
}

/// Example 5: Real-World Scenario
func exampleRealWorldScenario() {
    print("Example 5: Real-World Scenario")
    print("==============================\n")

    // Create a week's worth of meals
    var meals: [PlannedMeal] = []
    let startDate = Calendar.current.startOfDay(for: Date())

    for day in 0..<7 {
        guard let mealDate = Calendar.current.date(byAdding: .day, value: day, to: startDate) else {
            continue
        }

        // Breakfast
        let breakfast = PlannedMeal(
            date: mealDate.addingTimeInterval(8 * 3600), // 8 AM
            mealType: .breakfast,
            recipeName: "Breakfast Bowl",
            recipeInstructions: "Mix ingredients",
            ingredients: ["oats", "milk", "banana", "honey"],
            cookingTime: 10,
            prepTime: 20
        )

        // Lunch
        let lunch = PlannedMeal(
            date: mealDate.addingTimeInterval(13 * 3600), // 1 PM
            mealType: .lunch,
            recipeName: "Sandwich",
            recipeInstructions: "Assemble sandwich",
            ingredients: ["bread", "chicken", "lettuce", "tomato", "cheese"],
            cookingTime: 15,
            prepTime: 15
        )

        // Dinner
        let dinner = PlannedMeal(
            date: mealDate.addingTimeInterval(19 * 3600), // 7 PM
            mealType: .dinner,
            recipeName: "Stir Fry",
            recipeInstructions: "Stir fry vegetables with protein",
            ingredients: ["rice", "chicken", "broccoli", "carrot", "soy sauce"],
            cookingTime: 25,
            prepTime: 30
        )

        meals.append(contentsOf: [breakfast, lunch, dinner])
    }

    let weekPlan = MealPlan(
        name: "Week Plan",
        goal: .healthyEating,
        startDate: startDate,
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: startDate)!,
        dailyCalorieTarget: 2000,
        dailyProteinTarget: 150,
        dailyCarbsTarget: 200,
        dailyFatTarget: 65,
        meals: meals
    )

    let inventory = ShoppingListGenerator.createSampleInventory()

    print("Planning meals for \(meals.count) meals over 7 days")
    print("")

    let shoppingList = ShoppingListGenerator.shared.generateShoppingList(
        from: weekPlan,
        inventory: inventory
    )

    ShoppingListGenerator.printShoppingList(shoppingList)

    print("💡 Tips:")
    print("  • Items appearing multiple times are aggregated")
    print("  • Inventory items are automatically deducted")
    print("  • Items are categorized for easier shopping")
}

// MARK: - Run All Examples

/// Run all examples (call this from a test or debug view)
func runAllExamples() {
    print("\n\n")
    print("╔═══════════════════════════════════════════╗")
    print("║  Shopping List Generator - Test Suite    ║")
    print("╚═══════════════════════════════════════════╝")
    print("\n")

    exampleBasicGeneration()
    print("\n" + String(repeating: "═", count: 50) + "\n")

    exampleWithInventoryDeduction()
    print("\n" + String(repeating: "═", count: 50) + "\n")

    exampleConvertToShoppingItems()
    print("\n" + String(repeating: "═", count: 50) + "\n")

    exampleEmptyList()
    print("\n" + String(repeating: "═", count: 50) + "\n")

    exampleRealWorldScenario()
    print("\n" + String(repeating: "═", count: 50) + "\n")

    print("\n✅ All examples completed!")
}
