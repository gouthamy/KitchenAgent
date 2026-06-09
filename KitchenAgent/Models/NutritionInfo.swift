//
//  NutritionInfo.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class NutritionInfo {
    var calories: Int
    var protein: Double // grams
    var carbs: Double // grams
    var fat: Double // grams
    var fiber: Double // grams
    var sugar: Double // grams

    init(calories: Int, protein: Double, carbs: Double, fat: Double, fiber: Double, sugar: Double) {
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
    }
}

// For non-SwiftData usage
struct NutritionData: Codable {
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugar: Double
}
