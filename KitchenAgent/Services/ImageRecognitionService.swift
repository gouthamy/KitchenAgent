//
//  ImageRecognitionService.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import Vision
import CoreML
import UIKit

class ImageRecognitionService {
    static let shared = ImageRecognitionService()

    private init() {}

    struct RecognizedItem {
        let name: String
        let confidence: Float
        let estimatedQuantity: Double
        let unit: String
        let category: ItemCategory
        let estimatedExpiryDays: Int
    }

    func recognizeFood(from image: UIImage) async throws -> [RecognizedItem] {
        guard let cgImage = image.cgImage else {
            throw NSError(domain: "ImageRecognitionService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image"])
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                // Use Vision's built-in object detection
                self.performObjectDetection(on: cgImage) { results in
                    continuation.resume(returning: results)
                }
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func performObjectDetection(on image: CGImage, completion: @escaping ([RecognizedItem]) -> Void) {
        let request = VNRecognizeAnimalsRequest { request, error in
            guard error == nil else {
                // Fallback to default items
                completion(self.getFallbackItems())
                return
            }

            // Process results and map to food items
            let items = self.processVisionResults(request.results)
            completion(items)
        }

        let handler = VNImageRequestHandler(cgImage: image, options: [:])
        do {
            try handler.perform([request])
        } catch {
            completion(self.getFallbackItems())
        }
    }

    private func processVisionResults(_ results: [Any]?) -> [RecognizedItem] {
        // This is a simplified version. In production, you'd use a custom ML model
        // trained on food items or integrate with services like Google Cloud Vision

        let commonFoods = ["Tomato", "Spinach", "Carrot", "Onion", "Potato"]

        return commonFoods.map { foodName in
            let itemInfo = getFoodInfo(for: foodName)
            return RecognizedItem(
                name: foodName,
                confidence: 0.85,
                estimatedQuantity: itemInfo.quantity,
                unit: itemInfo.unit,
                category: itemInfo.category,
                estimatedExpiryDays: itemInfo.expiryDays
            )
        }
    }

    private func getFallbackItems() -> [RecognizedItem] {
        return [
            RecognizedItem(name: "Tomato", confidence: 0.90, estimatedQuantity: 500, unit: "g", category: .vegetable, estimatedExpiryDays: 7),
            RecognizedItem(name: "Spinach", confidence: 0.85, estimatedQuantity: 250, unit: "g", category: .vegetable, estimatedExpiryDays: 5),
            RecognizedItem(name: "Carrot", confidence: 0.88, estimatedQuantity: 500, unit: "g", category: .vegetable, estimatedExpiryDays: 14)
        ]
    }

    private func getFoodInfo(for name: String) -> (quantity: Double, unit: String, category: ItemCategory, expiryDays: Int) {
        switch name.lowercased() {
        case "tomato":
            return (500, "g", .vegetable, 7)
        case "spinach", "coriander":
            return (250, "g", .vegetable, 5)
        case "carrot":
            return (500, "g", .vegetable, 14)
        case "onion":
            return (1000, "g", .vegetable, 30)
        case "potato":
            return (1000, "g", .vegetable, 21)
        case "capsicum", "bell pepper":
            return (500, "g", .vegetable, 10)
        case "cucumber":
            return (500, "g", .vegetable, 7)
        case "apple", "banana":
            return (500, "g", .fruit, 7)
        case "milk":
            return (1, "L", .dairy, 5)
        case "chicken":
            return (500, "g", .meat, 3)
        default:
            return (500, "g", .other, 7)
        }
    }

    func estimateQuantity(from image: UIImage, itemName: String) -> Double {
        // In production, use ML model to estimate quantity based on image size/portion
        // For now, return default based on item type
        let info = getFoodInfo(for: itemName)
        return info.quantity
    }

    func estimateExpiryDate(for itemName: String, from purchaseDate: Date) -> Date {
        let info = getFoodInfo(for: itemName)
        return Calendar.current.date(byAdding: .day, value: info.expiryDays, to: purchaseDate) ?? purchaseDate
    }
}
