import UIKit
import Vision

struct RecognizedFoodItem {
    let name: String
    let estimatedQuantity: Double
    let category: ItemCategory
    let confidence: Float
}

final class ImageRecognitionService {
    static let shared = ImageRecognitionService()
    private init() {}

    /// Uses Apple's on-device Vision classifier to identify food in an image.
    func recognizeFood(from image: UIImage) async throws -> [RecognizedFoodItem] {
        guard let cgImage = image.cgImage else { return [] }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNClassifyImageRequest { request, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                let observations = (request.results as? [VNClassificationObservation]) ?? []

                // Keep only confident labels, map to your model.
                let items = observations
                    .filter { $0.confidence > 0.2 }
                    .prefix(3)
                    .map { obs in
                        RecognizedFoodItem(
                            name: obs.identifier.capitalized,
                            estimatedQuantity: 100,                 // sensible default in grams
                            category: Self.category(for: obs.identifier),
                            confidence: obs.confidence
                        )
                    }

                continuation.resume(returning: Array(items))
            }

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    /// Rough mapping from a recognized label to your ItemCategory.
    private static func category(for label: String) -> ItemCategory {
        let l = label.lowercased()
        if ["apple", "banana", "orange", "berry", "grape", "mango", "fruit"].contains(where: l.contains) { return .fruit }
        if ["tomato", "potato", "carrot", "onion", "pepper", "lettuce", "vegetable"].contains(where: l.contains) { return .vegetable }
        if ["chicken", "beef", "pork", "fish", "meat"].contains(where: l.contains) { return .meat }
        if ["milk", "cheese", "yogurt", "butter", "dairy"].contains(where: l.contains) { return .dairy }
        if ["rice", "bread", "pasta", "grain", "wheat"].contains(where: l.contains) { return .grain }
        return .other
    }

    /// You likely already have this — kept for compatibility with AddItemView.
    func estimateExpiryDate(for itemName: String, from purchaseDate: Date) -> Date {
        // Simple heuristic; replace with your existing logic if you have one.
        let days: Int
        switch category(for: itemName) {
        case .fruit, .vegetable: days = 7
        case .meat: days = 3
        case .dairy: days = 10
        case .grain: days = 180
        case .spice: days = 365
        case .other: days = 14
        }
        return Calendar.current.date(byAdding: .day, value: days, to: purchaseDate) ?? purchaseDate
    }
}
