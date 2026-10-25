import UIKit

/// How a tile looks, on the board and in the editor preview.
final class TileFaceView: UIView {
    private let photoView = UIImageView()
    private let centerStack = UIStackView()
    private let wordsLabel = UILabel()
    private let titleLabel = UILabel()
    private let pillStack = UIStackView()
    private let wordsPill = PillLabel()
    private let titlePill = PillLabel()
    private let badgePill = PillLabel()

    /// Builds every piece a tile can show (photo, centered words/title, bottom-left name pills,
    /// top-right badge) and positions them with Auto Layout. configure() later decides which pieces
    /// are visible.
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 16
        clipsToBounds = true
        isAccessibilityElement = false

        photoView.contentMode = .scaleAspectFill
        photoView.clipsToBounds = true
        photoView.prepared()

        centerStack.axis = .vertical
        centerStack.spacing = 6
        centerStack.alignment = .center
        for l in [wordsLabel, titleLabel] {
            l.textColor = Palette.ink
            l.textAlignment = .center
            l.numberOfLines = 2
            centerStack.addArrangedSubview(l)
        }
        titleLabel.font = Fonts.make(18, .medium)
        centerStack.prepared()

        pillStack.axis = .vertical
        pillStack.spacing = 4
        pillStack.alignment = .leading
        pillStack.addArrangedSubview(wordsPill)
        pillStack.addArrangedSubview(titlePill)
        pillStack.prepared()
        wordsPill.font = Fonts.make(16, .medium)
        titlePill.font = Fonts.make(18, .medium)

        badgePill.font = .systemFont(ofSize: 12)
        badgePill.backgroundColor = UIColor.white.withAlphaComponent(0.85)
        badgePill.insets = UIEdgeInsets(top: 2, left: 9, bottom: 2, right: 9)
        badgePill.prepared()

        addSubview(photoView)
        addSubview(centerStack)
        addSubview(pillStack)
        addSubview(badgePill)
        photoView.pin(to: self)
        NSLayoutConstraint.activate([
            centerStack.centerXAnchor.constraint(equalTo: centerXAnchor),
            centerStack.centerYAnchor.constraint(equalTo: centerYAnchor),
            centerStack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 8),
            centerStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -8),
            pillStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            pillStack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -10),
            pillStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
            badgePill.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            badgePill.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10)
        ])
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Updates the tile with new content. With a photo, the photo fills the tile and the words/name
    /// appear as pills at the bottom. Without one, you get a colored tile with the words and title
    /// in the middle. A badge such as "Edit" can appear in the corner.
    func configure(color: UIColor, words: String, title: String, photo: UIImage?, badge: String?) {
        backgroundColor = color
        let shownTitle = title.isEmpty ? "Name" : title
        photoView.image = photo
        photoView.isHidden = photo == nil
        centerStack.isHidden = photo != nil
        pillStack.isHidden = photo == nil

        wordsLabel.text = words
        wordsLabel.isHidden = words.isEmpty
        wordsLabel.font = Fonts.make(words.count <= 3 ? 48 : 22, .medium)
        titleLabel.text = shownTitle
        wordsPill.text = words
        wordsPill.isHidden = words.isEmpty
        titlePill.text = shownTitle

        badgePill.text = badge
        badgePill.isHidden = badge == nil
    }
}
