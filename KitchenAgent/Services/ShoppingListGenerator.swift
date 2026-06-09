//
//  ShoppingListGenerator.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation

/// Categorized shopping list item with aggregated quantity
struct CategorizedShoppingItem: Identifiable {
    let id = UUID()
    let name: String
    let quantity: Int
    let category: ItemCategory
    var isPurchased: Bool = false

    var displayText: String {
        "\(name) (\(quantity))"
    }
}

/// Shopping list organized by categories
struct CategorizedShoppingList {
    let items: [ItemCategory: [CategorizedShoppingItem]]

    var allCategories: [ItemCategory] {
        items.keys.sorted { $0.rawValue < $1.rawValue }
    }

    func items(for category: ItemCategory) -> [CategorizedShoppingItem] {
        items[category] ?? []
    }

    var totalItemCount: Int {
        items.values.reduce(0) { $0 + $1.count }
    }

    var isEmpty: Bool {
        totalItemCount == 0
    }
}

/// Service to generate shopping lists from meal plans
class ShoppingListGenerator {
    static let shared = ShoppingListGenerator()

    private init() {}

    /// Generate a shopping list from a meal plan, deducting existing inventory
    /// - Parameters:
    ///   - mealPlan: The meal plan to generate shopping list from
    ///   - inventory: Current fridge inventory to deduct from required items
    /// - Returns: Categorized shopping list with aggregated quantities
    func generateShoppingList(
        from mealPlan: MealPlan,
        inventory: [FridgeItem]
    ) -> CategorizedShoppingList {
        // Step 1: Collect all ingredients from all meals
        let allIngredients = collectIngredients(from: mealPlan)

        // Step 2: Aggregate quantities by ingredient name
        let aggregatedIngredients = aggregateIngredients(allIngredients)

        // Step 3: Deduct items already in inventory
        let neededIngredients = deductInventory(
            from: aggregatedIngredients,
            inventory: inventory
        )

        // Step 4: Categorize ingredients
        let categorizedItems = categorizeIngredients(neededIngredients)

        return CategorizedShoppingList(items: categorizedItems)
    }

    // MARK: - Private Helper Methods

    /// Collect all ingredients from all meals in the plan
    private func collectIngredients(from mealPlan: MealPlan) -> [String] {
        var allIngredients: [String] = []

        for meal in mealPlan.meals {
            allIngredients.append(contentsOf: meal.ingredients)
        }

        return allIngredients
    }

    /// Aggregate ingredients by name, counting occurrences
    private func aggregateIngredients(_ ingredients: [String]) -> [String: Int] {
        var aggregated: [String: Int] = [:]

        for ingredient in ingredients {
            let normalizedName = normalizeIngredientName(ingredient)
            aggregated[normalizedName, default: 0] += 1
        }

        return aggregated
    }

    /// Deduct inventory items from required ingredients
    private func deductInventory(
        from aggregated: [String: Int],
        inventory: [FridgeItem]
    ) -> [String: Int] {
        var needed = aggregated

        // Create a set of normalized inventory item names for quick lookup
        let inventoryNames = Set(inventory.map { normalizeIngredientName($0.name) })

        // Deduct one quantity for each ingredient found in inventory
        for inventoryName in inventoryNames {
            if let currentQuantity = needed[inventoryName] {
                let newQuantity = currentQuantity - 1
                if newQuantity > 0 {
                    needed[inventoryName] = newQuantity
                } else {
                    needed.removeValue(forKey: inventoryName)
                }
            }
        }

        return needed
    }

    /// Categorize ingredients by type
    private func categorizeIngredients(_ ingredients: [String: Int]) -> [ItemCategory: [CategorizedShoppingItem]] {
        var categorized: [ItemCategory: [CategorizedShoppingItem]] = [:]

        for (name, quantity) in ingredients {
            let category = determineCategory(for: name)
            let item = CategorizedShoppingItem(
                name: name.capitalized,
                quantity: quantity,
                category: category
            )

            categorized[category, default: []].append(item)
        }

        // Sort items within each category alphabetically
        for category in categorized.keys {
            categorized[category]?.sort { $0.name < $1.name }
        }

        return categorized
    }

    /// Normalize ingredient name for comparison (lowercase, trimmed, singular)
    private func normalizeIngredientName(_ name: String) -> String {
        var normalized = name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // Remove common quantity words and measurements
        let quantityWords = ["cup", "cups", "tbsp", "tsp", "oz", "lb", "lbs", "g", "kg", "ml", "l",
                            "large", "medium", "small", "whole", "chopped", "diced", "sliced",
                            "fresh", "dried", "frozen", "canned", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]

        for word in quantityWords {
            normalized = normalized.replacingOccurrences(of: "\\b\(word)\\b", with: "", options: .regularExpression)
        }

        // Remove extra spaces
        normalized = normalized.components(separatedBy: .whitespaces)
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Convert plural to singular (basic rules)
        if normalized.hasSuffix("ies") {
            normalized = String(normalized.dropLast(3)) + "y"
        } else if normalized.hasSuffix("es") && !normalized.hasSuffix("oes") {
            normalized = String(normalized.dropLast(2))
        } else if normalized.hasSuffix("s") && !normalized.hasSuffix("ss") {
            normalized = String(normalized.dropLast(1))
        }

        return normalized.trimmingCharacters(in: .whitespaces)
    }

    /// Determine the category for an ingredient based on its name
    private func determineCategory(for ingredient: String) -> ItemCategory {
        let normalized = ingredient.lowercased().trimmingCharacters(in: .whitespaces)

        // Vegetables
        let vegetables = ["tomato", "carrot", "broccoli", "lettuce", "spinach", "kale", "onion",
                         "potato", "pepper", "capsicum", "bell pepper", "cucumber", "corn",
                         "pumpkin", "eggplant", "garlic", "ginger", "mushroom", "bean",
                         "pea", "lentil", "chickpea", "cabbage", "celery", "zucchini",
                         "squash", "beetroot", "radish", "cauliflower", "asparagus"]

        // Fruits
        let fruits = ["apple", "banana", "orange", "strawberry", "grape", "watermelon",
                     "lemon", "lime", "mango", "pineapple", "cherry", "peach", "pear",
                     "blueberry", "coconut", "kiwi", "avocado", "raspberry", "blackberry",
                     "cranberry", "plum", "apricot", "fig", "date", "papaya", "guava"]

        // Meat & Protein
        let meats = ["chicken", "beef", "pork", "fish", "salmon", "tuna", "shrimp",
                    "prawn", "turkey", "lamb", "duck", "bacon", "ham", "sausage",
                    "tofu", "tempeh", "seitan"]

        // Dairy
        let dairy = ["milk", "cheese", "yogurt", "yoghurt", "butter", "cream", "sour cream",
                    "cheddar", "mozzarella", "parmesan", "feta", "cottage cheese",
                    "ice cream", "whey", "ghee"]

        // Grains & Bread
        let grains = ["bread", "rice", "pasta", "noodle", "cereal", "oat", "quinoa",
                     "couscous", "barley", "wheat", "flour", "tortilla", "pita",
                     "bagel", "roll", "bun", "cracker"]

        // Spices & Seasonings
        let spices = ["salt", "pepper", "paprika", "cumin", "coriander", "turmeric",
                     "cinnamon", "nutmeg", "oregano", "basil", "thyme", "rosemary",
                     "parsley", "cilantro", "mint", "vanilla", "cardamom", "clove",
                     "bay leaf", "saffron", "chili", "cayenne"]

        // Check each category
        for vegetable in vegetables {
            if normalized.contains(vegetable) {
                return .vegetable
            }
        }

        for fruit in fruits {
            if normalized.contains(fruit) {
                return .fruit
            }
        }

        for meat in meats {
            if normalized.contains(meat) {
                return .meat
            }
        }

        for dairyItem in dairy {
            if normalized.contains(dairyItem) {
                return .dairy
            }
        }

        for grain in grains {
            if normalized.contains(grain) {
                return .grain
            }
        }

        for spice in spices {
            if normalized.contains(spice) {
                return .spice
            }
        }

        // Default to other if no match
        return .other
    }
}

// MARK: - Extensions

extension ShoppingListGenerator {
    /// Convert categorized shopping list to ShoppingItem models for persistence
    func convertToShoppingItems(_ categorizedList: CategorizedShoppingList) -> [ShoppingItem] {
        var shoppingItems: [ShoppingItem] = []

        for category in categorizedList.allCategories {
            let items = categorizedList.items(for: category)
            for item in items {
                let shoppingItem = ShoppingItem(
                    name: item.name,
                    quantity: "\(item.quantity)",
                    isPurchased: item.isPurchased
                )
                shoppingItems.append(shoppingItem)
            }
        }

        return shoppingItems
    }
}
