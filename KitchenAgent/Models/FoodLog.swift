//
//  FoodLog.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class FoodLog {
    var id: UUID
    var foodName: String
    var mealType: MealType
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String
    var imageData: Data?
    var timestamp: Date
    var notes: String?

    init(
        id: UUID = UUID(),
        foodName: String,
        mealType: MealType,
        calories: Int,
        protein: Double,
        carbs: Double,
        fat: Double,
        servingSize: String = "1 serving",
        imageData: Data? = nil,
        timestamp: Date = Date(),
        notes: String? = nil
    ) {
        self.id = id
        self.foodName = foodName
        self.mealType = mealType
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
        self.imageData = imageData
        self.timestamp = timestamp
        self.notes = notes
    }
}
