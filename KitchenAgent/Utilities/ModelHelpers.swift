//
//  ModelHelpers.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftData
import Foundation

extension ModelContext {
    /// Get existing UserSettings or create a new one
    /// This eliminates code duplication across multiple views
    func getOrCreateSettings() throws -> UserSettings {
        let descriptor = FetchDescriptor<UserSettings>()

        do {
            if let existing = try fetch(descriptor).first {
                return existing
            }

            // Create new settings
            let newSettings = UserSettings()
            insert(newSettings)

            do {
                try save()
            } catch {
                throw ModelError.saveFailed(error.localizedDescription)
            }

            return newSettings
        } catch let error as ModelError {
            throw error
        } catch {
            throw ModelError.fetchFailed(error.localizedDescription)
        }
    }
}

// MARK: - Custom Errors
enum ModelError: LocalizedError {
    case fetchFailed(String)
    case saveFailed(String)
    case deleteFailed(String)

    var errorDescription: String? {
        switch self {
        case .fetchFailed(let message):
            return "Failed to fetch data: \(message)"
        case .saveFailed(let message):
            return "Failed to save data: \(message)"
        case .deleteFailed(let message):
            return "Failed to delete data: \(message)"
        }
    }
}
