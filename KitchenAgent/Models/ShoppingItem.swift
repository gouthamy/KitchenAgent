//
//  ShoppingItem.swift
//  KitchenAgent
//
//  Created by Goutham Yenuganti on 6/8/26.
//

import Foundation
import SwiftData

@Model
final class ShoppingItem {
    var id: UUID
    var name: String
    var quantity: String
    var isPurchased: Bool
    var addedDate: Date

    init(id: UUID = UUID(), name: String, quantity: String, isPurchased: Bool = false, addedDate: Date = Date()) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.isPurchased = isPurchased
        self.addedDate = addedDate
    }
}
