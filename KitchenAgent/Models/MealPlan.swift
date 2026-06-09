//
//  MealPlan.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class MealPlan {
    var id: UUID
    var name: String // e.g., "Weight Loss Plan", "Maintenance Plan"
    var goal: DietGoal
    var startDate: Date
    var endDate: Date
    var dailyCalorieTarget: Int
    var dailyProteinTarget: Double
    var dailyCarbsTarget: Double
    var dailyFatTarget: Double
    var meals: [PlannedMeal]
    var isActive: Bool

    init(
        id: UUID = UUID(),
        name: String,
        goal: DietGoal,
        startDate: Date,
        endDate: Date,
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        meals: [PlannedMeal] = [],
        isActive: Bool = true
    ) {
        self.id = id
        self.name = name
        self.goal = goal
        self.startDate = startDate
        self.endDate = endDate
        self.dailyCalorieTarget = dailyCalorieTarget
        self.dailyProteinTarget = dailyProteinTarget
        self.dailyCarbsTarget = dailyCarbsTarget
        self.dailyFatTarget = dailyFatTarget
        self.meals = meals
        self.isActive = isActive
    }
}

@Model
final class PlannedMeal {
    var id: UUID
    var date: Date
    var mealType: MealType
    var recipeName: String
    var recipeInstructions: String
    var ingredients: [String]
    var nutrition: NutritionData?
    var cookingTime: Int
    var prepTime: Int // minutes before meal time to start cooking
    var reminderSet: Bool
    var isCompleted: Bool

    init(
        id: UUID = UUID(),
        date: Date,
        mealType: MealType,
        recipeName: String,
        recipeInstructions: String,
        ingredients: [String],
        nutrition: NutritionData? = nil,
        cookingTime: Int,
        prepTime: Int = 30,
        reminderSet: Bool = false,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.date = date
        self.mealType = mealType
        self.recipeName = recipeName
        self.recipeInstructions = recipeInstructions
        self.ingredients = ingredients
        self.nutrition = nutrition
        self.cookingTime = cookingTime
        self.prepTime = prepTime
        self.reminderSet = reminderSet
        self.isCompleted = isCompleted
    }

    var scheduledTime: Date {
        date
    }

    var cookingStartTime: Date {
        Calendar.current.date(byAdding: .minute, value: -prepTime, to: date) ?? date
    }
}

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case morningSnack = "Morning Snack"
    case lunch = "Lunch"
    case eveningSnack = "Evening Snack"
    case dinner = "Dinner"

    var defaultTime: (hour: Int, minute: Int) {
        switch self {
        case .breakfast: return (8, 0)
        case .morningSnack: return (11, 0)
        case .lunch: return (13, 0)
        case .eveningSnack: return (17, 0)
        case .dinner: return (20, 0)
        }
    }

    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .morningSnack: return "cup.and.saucer.fill"
        case .lunch: return "sun.max.fill"
        case .eveningSnack: return "cup.and.saucer"
        case .dinner: return "moon.stars.fill"
        }
    }
}

enum DietGoal: String, Codable, CaseIterable {
    case weightLoss = "Weight Loss"
    case maintenance = "Maintenance"
    case muscleGain = "Muscle Gain"
    case healthyEating = "Healthy Eating"

    var description: String {
        switch self {
        case .weightLoss: return "Calorie deficit for weight loss"
        case .maintenance: return "Maintain current weight"
        case .muscleGain: return "Calorie surplus for muscle gain"
        case .healthyEating: return "Balanced nutrition"
        }
    }

    var calorieModifier: Double {
        switch self {
        case .weightLoss: return 0.8 // 20% deficit
        case .maintenance: return 1.0
        case .muscleGain: return 1.2 // 20% surplus
        case .healthyEating: return 1.0
        }
    }
}
