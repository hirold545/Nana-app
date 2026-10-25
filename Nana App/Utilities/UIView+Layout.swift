import UIKit

/// Small helpers for building views in code.
extension UIView {
    @discardableResult
    /// Turns off the old autoresizing system so Auto Layout constraints can be used, and returns
    /// the view so calls can be chained.
    func prepared() -> Self {
        translatesAutoresizingMaskIntoConstraints = false
        return self
    }

    /// Makes this view fill another view, optionally leaving padding on each side.
    func pin(to other: UIView, insets: UIEdgeInsets = .zero) {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: other.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: other.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: -insets.bottom)
        ])
    }
}
