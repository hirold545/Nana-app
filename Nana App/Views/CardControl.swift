import UIKit

/// A big tappable (or dashed, non-tappable) activity card.
final class CardControl: UIControl {
    private let dashed: Bool

    /// Builds the card: picks the icon (drawn glyph or system symbol), the title/subtitle labels
    /// and an optional "Coming soon" chip, then lays them out in a row.
    init(color: UIColor?, glyph: GlyphKind?, symbol: String?, title: String, subtitle: String, chip: String? = nil) {
        dashed = color == nil
        super.init(frame: .zero)
        layer.cornerRadius = 16
        backgroundColor = color
        let textColor = dashed ? Palette.text : Palette.ink

        let icon: UIView
        if let glyph {
            icon = GlyphView(kind: glyph).prepared()
        } else {
            let iv = UIImageView(image: UIImage(systemName: symbol ?? "sparkles",
                                                withConfiguration: UIImage.SymbolConfiguration(pointSize: 52)))
            iv.tintColor = Palette.primary
            iv.contentMode = .scaleAspectFit
            icon = iv.prepared()
        }
        icon.widthAnchor.constraint(equalToConstant: 76).isActive = true
        icon.heightAnchor.constraint(equalToConstant: 76).isActive = true

        let t = UILabel()
        t.text = title
        t.font = Fonts.make(24, .medium, style: .title2)
        t.textColor = textColor
        t.numberOfLines = 0
        let s = UILabel()
        s.text = subtitle
        s.font = Fonts.make(16)
        s.textColor = dashed ? Palette.muted : Palette.ink
        s.numberOfLines = 0

        let text = UIStackView(arrangedSubviews: [t, s])
        text.axis = .vertical
        text.spacing = 6
        text.alignment = .leading
        if let chip {
            let c = PillLabel()
            c.text = chip
            c.font = Fonts.make(13, .medium)
            c.textColor = Palette.text
            c.backgroundColor = Palette.primary.withAlphaComponent(0.15)
            text.addArrangedSubview(c)
        }

        let row = UIStackView(arrangedSubviews: [icon, text])
        row.axis = .horizontal
        row.spacing = 18
        row.alignment = .center
        row.isUserInteractionEnabled = false
        row.prepared()
        addSubview(row)
        NSLayoutConstraint.activate([
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 22),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -22),
            row.centerYAnchor.constraint(equalTo: centerYAnchor),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 150)
        ])
        isUserInteractionEnabled = !dashed
        isAccessibilityElement = true
        accessibilityLabel = [title, subtitle, chip].compactMap { $0 }.joined(separator: ". ")
        accessibilityTraits = dashed ? .staticText : .button
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Makes the card slightly transparent while it is pressed, as visual feedback.
    override var isHighlighted: Bool { didSet { alpha = isHighlighted ? 0.85 : 1 } }

    /// For the dashed card, draws its outline in the right color for light/dark mode.
    override func layoutSubviews() {
        super.layoutSubviews()
        if dashed {
            layer.borderWidth = 2
            layer.borderColor = Palette.outline.resolvedColor(with: traitCollection).cgColor
        }
    }
}
