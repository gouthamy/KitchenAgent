//
//  Recipe.swift
//  KitchenAgent
//

import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var ingredients: [String]
    var steps: [String]
    var cookingTime: Int          // minutes
    var difficulty: RecipeDifficulty
    var isFavorite: Bool

    init(id: UUID = UUID(),
         name: String,
         ingredients: [String] = [],
         steps: [String] = [],
         cookingTime: Int = 0,
         difficulty: RecipeDifficulty = .easy,
         isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.ingredients = ingredients
        self.steps = steps
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.isFavorite = isFavorite
    }
}

enum RecipeDifficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}
