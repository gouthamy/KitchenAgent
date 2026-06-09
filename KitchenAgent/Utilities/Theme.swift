//
//  Theme.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

enum Theme {
    // MARK: - Colors
    enum Colors {
        static let primary = Color.green
        static let secondary = Color.gray
        static let accent = Color.purple
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let background = Color(.systemGray6)
        static let cardBackground = Color(.systemBackground)

        // Specific feature colors
        static let aiPurple = Color.purple
        static let recipesGreen = Color.green
        static let expiryOrange = Color.orange
        static let expiredRed = Color.red
    }

    // MARK: - Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 32
    }

    // MARK: - Corner Radius
    enum CornerRadius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 16
        static let xl: CGFloat = 20
        static let full: CGFloat = 1000 // For circles
    }

    // MARK: - Font Sizes
    enum FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let headline: CGFloat = 17
        static let title3: CGFloat = 20
        static let title2: CGFloat = 22
        static let title: CGFloat = 28
        static let largeTitle: CGFloat = 34
    }

    // MARK: - Shadow
    enum Shadow {
        static let light = (color: Color.black.opacity(0.05), radius: CGFloat(4), x: CGFloat(0), y: CGFloat(2))
        static let medium = (color: Color.black.opacity(0.1), radius: CGFloat(8), x: CGFloat(0), y: CGFloat(4))
        static let heavy = (color: Color.black.opacity(0.2), radius: CGFloat(12), x: CGFloat(0), y: CGFloat(6))
    }

    // MARK: - Animation
    enum Animation {
        static let quick = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let normal = SwiftUI.Animation.spring(response: 0.5, dampingFraction: 0.7)
        static let slow = SwiftUI.Animation.spring(response: 0.7, dampingFraction: 0.7)
    }
}
