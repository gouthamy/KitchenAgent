//
//  ItemImageProvider.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

/// Provides default images for common food items
struct ItemImageProvider {

    /// Get default SF Symbol icon for a food item
    static func getIcon(for itemName: String) -> String {
        let name = itemName.lowercased().trimmingCharacters(in: .whitespaces)

        switch name {
        // Vegetables
        case "tomato", "tomatoes":
            return "circle.fill" // Red circle represents tomato
        case "carrot", "carrots":
            return "carrot.fill"
        case "broccoli":
            return "leaf.fill"
        case "lettuce", "spinach", "kale", "cabbage":
            return "leaf.fill"
        case "onion", "onions":
            return "circle"
        case "potato", "potatoes":
            return "oval.fill"
        case "pepper", "peppers", "capsicum", "bell pepper":
            return "circle.hexagonpath.fill"
        case "cucumber":
            return "cylinder.fill"
        case "corn":
            return "cylinder.fill"
        case "pumpkin", "squash":
            return "circle.fill"

        // Fruits
        case "apple", "apples":
            return "apple.logo"
        case "banana", "bananas":
            return "moon.fill"
        case "orange", "oranges":
            return "circle.fill"
        case "strawberry", "strawberries":
            return "heart.fill"
        case "grape", "grapes":
            return "circle.grid.2x2.fill"
        case "watermelon":
            return "circle.fill"
        case "lemon", "lemons", "lime", "limes":
            return "circle"
        case "mango", "mangoes":
            return "oval.fill"
        case "pineapple":
            return "diamond.fill"
        case "cherry", "cherries":
            return "circle.circle.fill"

        // Dairy
        case "milk":
            return "drop.fill"
        case "cheese":
            return "square.fill"
        case "yogurt", "yoghurt":
            return "cup.and.saucer.fill"
        case "butter":
            return "square.fill"
        case "cream":
            return "drop.fill"
        case "egg", "eggs":
            return "oval.fill"

        // Meat & Protein
        case "chicken":
            return "flame.fill"
        case "beef", "steak":
            return "flame.fill"
        case "pork":
            return "flame.fill"
        case "fish":
            return "fish.fill"
        case "shrimp", "prawn":
            return "fish.fill"
        case "tofu":
            return "square.fill"

        // Grains & Bread
        case "bread":
            return "circle.grid.2x1.fill"
        case "rice":
            return "circle.grid.3x3.fill"
        case "pasta":
            return "waveform"
        case "cereal":
            return "circle.grid.3x3.fill"
        case "flour":
            return "square.fill"

        // Condiments & Spices
        case "salt":
            return "circle.dotted"
        case "pepper":
            return "circle.dotted"
        case "sugar":
            return "sparkles"
        case "oil":
            return "drop.fill"
        case "vinegar":
            return "drop"
        case "sauce", "ketchup", "mustard":
            return "drop.triangle.fill"

        // Beverages
        case "juice":
            return "cup.and.saucer.fill"
        case "soda", "cola":
            return "cup.and.saucer"
        case "water":
            return "drop.fill"
        case "coffee":
            return "cup.and.saucer.fill"
        case "tea":
            return "cup.and.saucer"

        default:
            return "fork.knife"
        }
    }

    /// Get color for the item icon
    static func getColor(for itemName: String) -> Color {
        let name = itemName.lowercased().trimmingCharacters(in: .whitespaces)

        switch name {
        // Red items
        case "tomato", "tomatoes", "strawberry", "strawberries", "cherry", "cherries", "watermelon":
            return .red

        // Orange items
        case "carrot", "carrots", "orange", "oranges", "pumpkin", "mango", "mangoes":
            return .orange

        // Yellow items
        case "lemon", "lemons", "banana", "bananas", "corn", "pineapple", "butter":
            return .yellow

        // Green items
        case "lettuce", "spinach", "kale", "cabbage", "broccoli", "cucumber", "lime", "limes", "pepper", "bell pepper", "capsicum":
            return .green

        // Purple items
        case "grape", "grapes", "eggplant", "plum":
            return .purple

        // Brown items
        case "potato", "potatoes", "onion", "onions", "bread", "coffee", "chocolate", "beans", "bean", "lentils", "lentil":
            return .brown

        // White/Cream items
        case "milk", "cream", "yogurt", "yoghurt", "rice", "flour", "cheese", "egg", "eggs", "tofu", "garlic":
            return .gray

        // Blue items
        case "blueberry", "blueberries":
            return .blue

        // Meat (red/pink)
        case "chicken", "beef", "pork", "steak", "fish", "shrimp", "prawn":
            return .red.opacity(0.7)

        default:
            return .green
        }
    }

    /// Get emoji representation for an item
    static func getEmoji(for itemName: String) -> String {
        let name = itemName.lowercased().trimmingCharacters(in: .whitespaces)

        switch name {
        // Vegetables
        case "tomato", "tomatoes": return "🍅"
        case "carrot", "carrots": return "🥕"
        case "broccoli": return "🥦"
        case "lettuce", "spinach", "kale": return "🥬"
        case "onion", "onions": return "🧅"
        case "potato", "potatoes": return "🥔"
        case "pepper", "peppers", "capsicum", "bell pepper": return "🫑"
        case "cucumber": return "🥒"
        case "corn": return "🌽"
        case "pumpkin": return "🎃"
        case "eggplant": return "🍆"
        case "garlic": return "🧄"
        case "ginger": return "🫚"
        case "mushroom", "mushrooms": return "🍄"

        // Fruits
        case "apple", "apples": return "🍎"
        case "banana", "bananas": return "🍌"
        case "orange", "oranges": return "🍊"
        case "strawberry", "strawberries": return "🍓"
        case "grape", "grapes": return "🍇"
        case "watermelon": return "🍉"
        case "lemon", "lemons", "lime", "limes": return "🍋"
        case "mango", "mangoes": return "🥭"
        case "pineapple": return "🍍"
        case "cherry", "cherries": return "🍒"
        case "peach", "peaches": return "🍑"
        case "pear", "pears": return "🍐"
        case "blueberry", "blueberries": return "🫐"
        case "coconut": return "🥥"
        case "kiwi": return "🥝"
        case "avocado": return "🥑"

        // Dairy
        case "milk": return "🥛"
        case "cheese": return "🧀"
        case "yogurt", "yoghurt": return "🥛"
        case "butter": return "🧈"
        case "egg", "eggs": return "🥚"
        case "ice cream": return "🍦"

        // Meat & Protein
        case "chicken": return "🍗"
        case "beef", "steak": return "🥩"
        case "pork", "bacon": return "🥓"
        case "fish": return "🐟"
        case "shrimp", "prawn": return "🦐"
        case "tofu": return "🥡"

        // Grains & Bread
        case "bread": return "🍞"
        case "rice": return "🍚"
        case "pasta": return "🍝"
        case "cereal": return "🥣"
        case "croissant": return "🥐"
        case "bagel": return "🥯"

        // Legumes & Beans
        case "beans", "bean": return "🫘"
        case "peas", "pea": return "🫛"
        case "lentils", "lentil": return "🫘"
        case "chickpeas", "chickpea": return "🫘"

        // Prepared Foods
        case "pizza": return "🍕"
        case "burger", "hamburger": return "🍔"
        case "sandwich": return "🥪"
        case "taco": return "🌮"
        case "burrito": return "🌯"
        case "sushi": return "🍣"
        case "curry": return "🍛"
        case "soup": return "🍲"
        case "salad": return "🥗"

        // Beverages
        case "juice": return "🧃"
        case "coffee": return "☕️"
        case "tea": return "🍵"
        case "water": return "💧"
        case "wine": return "🍷"
        case "beer": return "🍺"

        // Desserts
        case "cake": return "🍰"
        case "cookie", "cookies": return "🍪"
        case "chocolate": return "🍫"
        case "candy": return "🍬"
        case "donut", "doughnut": return "🍩"

        // Condiments
        case "honey": return "🍯"
        case "jam": return "🍯"
        case "peanut butter": return "🥜"

        default: return "🍽️"
        }
    }

    /// Get a view representing the item with default styling
    static func getItemView(for itemName: String, size: CGFloat = 60) -> some View {
        ZStack {
            Circle()
                .fill(getColor(for: itemName).opacity(0.2))
                .frame(width: size, height: size)

            Text(getEmoji(for: itemName))
                .font(.system(size: size * 0.6))
        }
    }
}
