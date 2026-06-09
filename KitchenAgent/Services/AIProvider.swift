//
//  AIProvider.swift
//  KitchenAgent
//
//  Multi-AI Provider Support (OpenAI, Claude, etc.)
//

import Foundation
import UIKit

enum AIProvider: String, CaseIterable, Codable {
    case openai = "OpenAI (GPT-4)"
    case claude = "Anthropic Claude"

    var displayName: String {
        self.rawValue
    }

    var icon: String {
        switch self {
        case .openai: return "brain.head.profile"
        case .claude: return "sparkles"
        }
    }

    var description: String {
        switch self {
        case .openai: return "GPT-4o-mini - Fast and cost-effective"
        case .claude: return "Claude 3.5 Sonnet - High quality responses"
        }
    }

    var apiKeyUserDefaultsKey: String {
        switch self {
        case .openai: return "chatgpt_api_key"
        case .claude: return "claude_api_key"
        }
    }

    var endpoint: String {
        switch self {
        case .openai: return "https://api.openai.com/v1/chat/completions"
        case .claude: return "https://api.anthropic.com/v1/messages"
        }
    }
}

protocol AIService: Sendable {
    func generateMealPlan(
        goal: DietGoal,
        duration: Int,
        dailyCalorieTarget: Int,
        dailyProteinTarget: Double,
        dailyCarbsTarget: Double,
        dailyFatTarget: Double,
        cuisine: String,
        dietaryPreferences: [String]
    ) async throws -> [PlannedMeal]

    func analyzeFoodImage(_ image: UIImage) async throws -> FoodNutrition
}

// Make services Sendable
extension OpenAIService: @unchecked Sendable {}
extension ClaudeService: @unchecked Sendable {}

class AIServiceFactory {
    static func getService(provider: AIProvider) -> AIService {
        switch provider {
        case .openai:
            return OpenAIService.shared
        case .claude:
            return ClaudeService.shared
        }
    }

    static var currentProvider: AIProvider {
        get {
            if let providerString = UserDefaults.standard.string(forKey: "ai_provider"),
               let provider = AIProvider(rawValue: providerString) {
                return provider
            }
            return .openai // Default
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "ai_provider")
        }
    }
}
