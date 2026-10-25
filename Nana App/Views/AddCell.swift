import UIKit

/// The dashed "Add a tile" button shown at the end of the grid in edit mode.
final class AddCell: UICollectionViewCell {
    static let id = "AddCell"
    private let dash = CAShapeLayer()

    /// Builds the dashed border, the purple + circle and the "Add a tile" label.
    override init(frame: CGRect) {
        super.init(frame: frame)
        dash.fillColor = UIColor.clear.cgColor
        dash.lineWidth = 2
        dash.lineDashPattern = [6, 5]
        contentView.layer.addSublayer(dash)

        let plus = UIImageView(image: UIImage(systemName: "plus",
                                              withConfiguration: UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)))
        plus.tintColor = .white
        plus.contentMode = .center
        plus.backgroundColor = Palette.primary
        plus.layer.cornerRadius = 28
        plus.clipsToBounds = true
        plus.widthAnchor.constraint(equalToConstant: 56).isActive = true
        plus.heightAnchor.constraint(equalToConstant: 56).isActive = true

        let label = UILabel()
        label.text = "Add a tile"
        label.font = Fonts.make(20, .medium)
        label.textColor = Palette.text

        let stack = UIStackView(arrangedSubviews: [plus, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.prepared()
        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
        isAccessibilityElement = true
        accessibilityLabel = "Add a tile"
        accessibilityTraits = .button
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Redraws the dashed outline to match the cell size and the current light/dark color.
    override func layoutSubviews() {
        super.layoutSubviews()
        dash.frame = contentView.bounds
        dash.path = UIBezierPath(roundedRect: contentView.bounds.insetBy(dx: 1, dy: 1), cornerRadius: 16).cgPath
        dash.strokeColor = Palette.outline.resolvedColor(with: traitCollection).cgColor
    }
}
