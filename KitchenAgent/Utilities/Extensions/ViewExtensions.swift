//
//  ViewExtensions.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import SwiftUI

extension View {
    /// Apply card styling with shadow
    func cardStyle() -> some View {
        self
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.cardBackground)
            .cornerRadius(Theme.CornerRadius.md)
            .shadow(
                color: Theme.Shadow.light.color,
                radius: Theme.Shadow.light.radius,
                x: Theme.Shadow.light.x,
                y: Theme.Shadow.light.y
            )
    }

    /// Apply primary button styling
    func primaryButtonStyle(color: Color = Theme.Colors.primary) -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(color)
            .cornerRadius(Theme.CornerRadius.md)
    }

    /// Apply secondary button styling
    func secondaryButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(Theme.Colors.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.background)
            .cornerRadius(Theme.CornerRadius.md)
    }

    /// Apply destructive button styling
    func destructiveButtonStyle() -> some View {
        self
            .font(.headline)
            .foregroundColor(Theme.Colors.error)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Theme.Colors.error.opacity(0.1))
            .cornerRadius(Theme.CornerRadius.md)
    }

    /// Apply medium shadow
    func mediumShadow() -> some View {
        self.shadow(
            color: Theme.Shadow.medium.color,
            radius: Theme.Shadow.medium.radius,
            x: Theme.Shadow.medium.x,
            y: Theme.Shadow.medium.y
        )
    }

    /// Apply heavy shadow
    func heavyShadow() -> some View {
        self.shadow(
            color: Theme.Shadow.heavy.color,
            radius: Theme.Shadow.heavy.radius,
            x: Theme.Shadow.heavy.x,
            y: Theme.Shadow.heavy.y
        )
    }
}
