//
//  OpenAIService.swift
//  KitchenAgent
//
//  OpenAI (ChatGPT) Implementation
//

import Foundation
import UIKit

class OpenAIService: AIService {
    static let shared = OpenAIService()
    private init() {}

    nonisolated func generateMealPlan(
        goal: DietGoal,
        duration: Int,
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        cuisine: String,
        dietaryPreferences: [String]
    ) async throws -> [PlannedMeal] {
        // Delegate to existing MealPlanGeneratorService
        return try await MealPlanGeneratorService.shared.generateMealPlan(
            goal: goal,
            duration: duration,
            dailyCalorieTarget: dailyCalorieTarget,
            dailyProteinTarget: dailyProteinTarget,
            dailyCarbsTarget: dailyCarbsTarget,
            dailyFatTarget: dailyFatTarget,
            cuisine: cuisine,
            dietaryPreferences: dietaryPreferences
        )
    }

    nonisolated func analyzeFoodImage(_ image: UIImage) async throws -> FoodNutrition {
        // Delegate to existing FoodRecognitionService
        return try await FoodRecognitionService.shared.analyzeFoodImage(image)
    }
}
