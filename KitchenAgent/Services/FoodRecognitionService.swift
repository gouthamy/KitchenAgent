//
//  FoodRecognitionService.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import UIKit
import Vision

struct FoodNutrition {
    let foodName: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let servingSize: String
}

class FoodRecognitionService {
    static let shared = FoodRecognitionService()

    private init() {}

    /// Analyze food image using ChatGPT Vision API to detect food and estimate nutrition
    func analyzeFoodImage(_ image: UIImage) async throws -> FoodNutrition {
        // Get API key
        guard let apiKey = UserDefaults.standard.string(forKey: "chatgpt_api_key"), !apiKey.isEmpty else {
            throw FoodRecognitionError.noAPIKey
        }

        // Convert image to base64
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            throw FoodRecognitionError.invalidImage
        }
        let base64Image = imageData.base64EncodedString()

        // Call ChatGPT Vision API
        let nutrition = try await callChatGPTVision(base64Image: base64Image, apiKey: apiKey)
        return nutrition
    }

    private func callChatGPTVision(base64Image: String, apiKey: String) async throws -> FoodNutrition {
        guard let url = URL(string: "https://api.openai.com/v1/chat/completions") else {
            throw FoodRecognitionError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30

        let prompt = """
        Analyze this food image and provide detailed nutrition information.

        Identify:
        1. The name of the food/dish
        2. Approximate serving size
        3. Estimated calories
        4. Protein (in grams)
        5. Carbohydrates (in grams)
        6. Fat (in grams)

        If multiple items are visible, provide totals for the entire meal.

        Respond ONLY with valid JSON in this exact format:
        {
          "foodName": "Food name",
          "servingSize": "1 plate",
          "calories": 500,
          "protein": 25.0,
          "carbs": 60.0,
          "fat": 15.0
        }
        """

        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 500
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw FoodRecognitionError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("ChatGPT Vision API Error: \(errorMessage)")
            throw FoodRecognitionError.apiError(httpResponse.statusCode, errorMessage)
        }

        // Parse response
        let chatGPTResponse = try JSONDecoder().decode(ChatGPTResponse.self, from: data)

        guard let content = chatGPTResponse.choices.first?.message.content else {
            throw FoodRecognitionError.noContent
        }

        // Extract JSON from response
        let jsonString = extractJSON(from: content)

        guard let jsonData = jsonString.data(using: .utf8) else {
            throw FoodRecognitionError.invalidJSON
        }

        let nutritionResponse = try JSONDecoder().decode(FoodNutritionResponse.self, from: jsonData)

        return FoodNutrition(
            foodName: nutritionResponse.foodName,
            calories: nutritionResponse.calories,
            protein: nutritionResponse.protein,
            carbs: nutritionResponse.carbs,
            fat: nutritionResponse.fat,
            servingSize: nutritionResponse.servingSize
        )
    }

    private func extractJSON(from text: String) -> String {
        // Try to find JSON object in the response
        if let startIndex = text.firstIndex(of: "{"),
           let endIndex = text.lastIndex(of: "}") {
            return String(text[startIndex...endIndex])
        }
        return text
    }
}

// MARK: - Models

struct FoodNutritionResponse: Codable {
    let foodName: String
    let servingSize: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
}

enum FoodRecognitionError: LocalizedError {
    case noAPIKey
    case invalidImage
    case invalidURL
    case invalidResponse
    case apiError(Int, String)
    case noContent
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .noAPIKey:
            return "ChatGPT API key not configured"
        case .invalidImage:
            return "Invalid image format"
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code, let message):
            return "API Error (\(code)): \(message)"
        case .noContent:
            return "No content in response"
        case .invalidJSON:
            return "Invalid JSON format"
        }
    }
}
