//
//  FridgeItem.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class FridgeItem {
    var id: UUID
    var name: String
    var quantity: Double
    var unit: String
    var purchaseDate: Date
    var expiryDate: Date?
    var location: StorageLocation
    var notes: String?
    var imageData: Data?
    var category: ItemCategory
    var isExpiringSoon: Bool {
        guard let expiryDate = expiryDate else { return false }
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
        return daysUntilExpiry <= 3 && daysUntilExpiry >= 0
    }
    var isExpired: Bool {
        guard let expiryDate = expiryDate else { return false }
        return expiryDate < Date()
    }
    var daysUntilExpiry: Int? {
        guard let expiryDate = expiryDate else { return nil }
        return Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day
    }

    /// Get emoji for the food item
    var emoji: String {
        let name = self.name.lowercased().trimmingCharacters(in: .whitespaces)

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
        case "beans", "bean": return "🫘"
        case "peas", "pea": return "🫛"
        case "lentils", "lentil": return "🫘"
        case "chickpeas", "chickpea": return "🫘"
        case "cabbage": return "🥬"

        // Fruits
        case "apple", "apples": return "🍎"
        case "banana", "bananas": return "🍌"
        case "orange", "oranges": return "🍊"
        case "strawberry", "strawberries": return "🍓"
        case "grape", "grapes": return "🍇"
        case "watermelon": return "🍉"
        case "lemon", "lemons": return "🍋"
        case "lime", "limes": return "🍋"
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

        // Meat
        case "chicken": return "🍗"
        case "beef", "steak": return "🥩"
        case "pork", "bacon": return "🥓"
        case "fish": return "🐟"
        case "shrimp", "prawn": return "🦐"
        case "tofu": return "🥡"

        // Grains
        case "bread": return "🍞"
        case "rice": return "🍚"
        case "pasta": return "🍝"
        case "cereal": return "🥣"

        // Default
        default: return category.icon
        }
    }

    /// Get color for the food item
    var color: Color {
        let name = self.name.lowercased().trimmingCharacters(in: .whitespaces)

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
        case "lettuce", "spinach", "kale", "cabbage", "broccoli", "cucumber", "lime", "limes", "pepper", "bell pepper", "capsicum", "peas", "pea":
            return .green
        // Purple items
        case "grape", "grapes", "eggplant":
            return .purple
        // Brown items
        case "potato", "potatoes", "onion", "onions", "bread", "beans", "bean", "lentils", "lentil", "chickpeas", "chickpea":
            return .brown
        // White/Gray items
        case "milk", "yogurt", "yoghurt", "rice", "cheese", "egg", "eggs", "tofu", "garlic":
            return .gray
        // Default - use category color
        default:
            switch category {
            case .vegetable: return .green
            case .fruit: return .red
            case .meat: return .red.opacity(0.7)
            case .dairy: return .gray
            case .grain: return .brown
            default: return .green
            }
        }
    }

    init(id: UUID = UUID(), name: String, quantity: Double, unit: String, purchaseDate: Date, expiryDate: Date? = nil, location: StorageLocation, notes: String? = nil, imageData: Data? = nil, category: ItemCategory) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.purchaseDate = purchaseDate
        self.expiryDate = expiryDate
        self.location = location
        self.notes = notes
        self.imageData = imageData
        self.category = category
    }
}

enum StorageLocation: String, Codable, CaseIterable {
    case fridge = "Fridge"
    case freezer = "Freezer"
    case pantry = "Pantry"

    var icon: String {
        switch self {
        case .fridge: return "refrigerator"
        case .freezer: return "snowflake"
        case .pantry: return "cabinet"
        }
    }
}

enum ItemCategory: String, Codable, CaseIterable {
    case vegetable = "Vegetable"
    case fruit = "Fruit"
    case meat = "Meat"
    case dairy = "Dairy"
    case grain = "Grain"
    case spice = "Spice"
    case other = "Other"

    var icon: String {
        switch self {
        case .vegetable: return "🥬"
        case .fruit: return "🍎"
        case .meat: return "🥩"
        case .dairy: return "🥛"
        case .grain: return "🌾"
        case .spice: return "🧂"
        case .other: return "📦"
        }
    }
}
