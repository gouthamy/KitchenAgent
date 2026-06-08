import SwiftUI

/// Provides a predefined image for a food item, falling back to the
/// category emoji when no matching asset is bundled.
enum CategoryImageProvider {

    /// Looks for an asset named after the item first (e.g. "tomato"),
    /// then after the category (e.g. "vegetable"). Returns nil if neither exists.
    static func assetName(forItemNamed name: String, category: ItemCategory) -> String? {
        let itemAsset = name.lowercased().replacingOccurrences(of: " ", with: "_")
        if UIImage(named: itemAsset) != nil { return itemAsset }

        let categoryAsset = category.rawValue.lowercased()
        if UIImage(named: categoryAsset) != nil { return categoryAsset }

        return nil
    }

    /// A ready-to-use SwiftUI view: real photo if available, else the emoji.
    @ViewBuilder
    static func image(forItemNamed name: String, category: ItemCategory) -> some View {
        if let asset = assetName(forItemNamed: name, category: category) {
            Image(asset)
                .resizable()
                .scaledToFill()
        } else {
            Text(category.icon)            // your existing emoji
                .font(.system(size: 50))
        }
    }
}
