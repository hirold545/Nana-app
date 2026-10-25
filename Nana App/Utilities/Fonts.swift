import UIKit

/// Creates fonts that grow or shrink with the user text-size setting (Dynamic Type).
enum Fonts {
    /// Returns a system font of the given size and weight that scales with accessibility settings.
    static func make(_ size: CGFloat, _ weight: UIFont.Weight = .regular,
                     style: UIFont.TextStyle = .body) -> UIFont {
        UIFontMetrics(forTextStyle: style).scaledFont(for: .systemFont(ofSize: size, weight: weight))
    }
}
