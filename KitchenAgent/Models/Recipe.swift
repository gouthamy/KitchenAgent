//
//  Recipe.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class Recipe {
    var id: UUID
    var name: String
    var imageName: String?
    var cookingTime: Int // in minutes
    var difficulty: Difficulty
    var ingredients: [String]
    var instructions: String
    var isFavorite: Bool

    init(id: UUID = UUID(), name: String, imageName: String? = nil, cookingTime: Int, difficulty: Difficulty, ingredients: [String], instructions: String, isFavorite: Bool = false) {
        self.id = id
        self.name = name
        self.imageName = imageName
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.ingredients = ingredients
        self.instructions = instructions
        self.isFavorite = isFavorite
    }
}

enum Difficulty: String, Codable, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}
