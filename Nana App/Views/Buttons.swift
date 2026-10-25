import UIKit

/// Pill-shaped buttons in the flat Material style.
enum Buttons {
    /// Builds a pill button with a title, an optional icon, an optional fill color and an optional
    /// outline. Every button in the app uses this so they all look the same.
    static func make(title: String, icon: String? = nil, fill: UIColor?, foreground: UIColor,
                     stroke: UIColor? = nil, height: CGFloat = 52, fontSize: CGFloat = 17) -> UIButton {
        var c = UIButton.Configuration.plain()
        c.title = title
        if let icon {
            c.image = UIImage(systemName: icon)
            c.imagePadding = 8
        }
        c.baseForegroundColor = foreground
        c.cornerStyle = .capsule
        c.background.backgroundColor = fill
        if let stroke {
            c.background.strokeColor = stroke
            c.background.strokeWidth = 1
        }
        c.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var a = attrs
            a.font = Fonts.make(fontSize, .medium)
            return a
        }
        let b = UIButton(configuration: c)
        b.translatesAutoresizingMaskIntoConstraints = false
        b.heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        return b
    }
}
