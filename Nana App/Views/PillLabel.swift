import UIKit

/// A label with a rounded white background.
final class PillLabel: UILabel {
    var insets = UIEdgeInsets(top: 3, left: 12, bottom: 3, right: 12)

    /// Sets up the label look: white background, dark text, centered, with rounded clipping.
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        textColor = Palette.ink
        textAlignment = .center
        clipsToBounds = true
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Draws the text inside the label, leaving padding (insets) so the text does not touch the
    /// pill border.
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }

    /// Tells Auto Layout how big the label wants to be: the text size plus the padding.
    override var intrinsicContentSize: CGSize {
        let s = super.intrinsicContentSize
        return CGSize(width: s.width + insets.left + insets.right, height: s.height + insets.top + insets.bottom)
    }

    /// Runs whenever the size changes. A corner radius of half the height makes a perfect pill
    /// (capsule) shape.
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.height / 2
    }
}
