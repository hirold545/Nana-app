import UIKit

/// A row of round color buttons. The selected color shows a check mark and a purple ring.
final class ColorSwatchRow: UIView {
    /// Called with the index of the color the user tapped.
    var onSelect: ((Int) -> Void)?
    private let stack = UIStackView()
    private var buttons: [UIButton] = []

    /// Builds one round button for each color and spreads them evenly across the row.
    init(colors: [UIColor], names: [String]) {
        super.init(frame: .zero)
        stack.distribution = .equalSpacing
        stack.prepared()
        addSubview(stack)
        stack.pin(to: self)
        for (i, color) in colors.enumerated() {
            let b = UIButton(type: .custom)
            b.backgroundColor = color
            b.layer.cornerRadius = 24
            b.tag = i
            b.accessibilityLabel = names[i]
            b.widthAnchor.constraint(equalToConstant: 48).isActive = true
            b.heightAnchor.constraint(equalToConstant: 48).isActive = true
            b.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            buttons.append(b)
            stack.addArrangedSubview(b)
        }
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Shows which color is selected (ring + check mark) and clears the others.
    func select(_ index: Int) {
        for (i, b) in buttons.enumerated() {
            let selected = i == index
            b.layer.borderWidth = selected ? 3 : 0
            b.layer.borderColor = Palette.primary.cgColor
            b.setImage(selected ? UIImage(systemName: "checkmark") : nil, for: .normal)
            b.tintColor = Palette.ink
            b.accessibilityTraits = selected ? [.button, .selected] : .button
        }
    }

    /// Passes the tapped color's index to whoever is listening (the controller).
    @objc private func tapped(_ b: UIButton) { onSelect?(b.tag) }
}
