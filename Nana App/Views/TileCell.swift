import UIKit

/// A grid cell that shows one tile using TileFaceView.
final class TileCell: UICollectionViewCell {
    static let id = "TileCell"
    let face = TileFaceView().prepared()
    var tileID = ""

    /// Puts the tile face inside the cell and lets VoiceOver treat the cell as a button.
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(face)
        face.pin(to: contentView)
        isAccessibilityElement = true
        accessibilityTraits = .button
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Fills the cell with ready-to-show values. The cell knows nothing about tiles or storage;
    /// the controller decides what to display (this keeps the View separate from the Model).
    func configure(id: String, name: String, color: UIColor, words: String, photo: UIImage?,
                   badge: String?, dimmed: Bool, playing: Bool) {
        tileID = id
        face.configure(color: color, words: words, title: name, photo: photo, badge: badge)
        face.alpha = dimmed ? 0.6 : 1
        accessibilityLabel = name
        setPlaying(playing, animated: false)
    }

    /// Makes the tile grow slightly while its sound is playing, and return to normal size
    /// afterwards.
    func setPlaying(_ playing: Bool, animated: Bool) {
        let t = playing ? CGAffineTransform(scaleX: 1.07, y: 1.07) : .identity
        if animated {
            UIView.animate(withDuration: 0.15) { self.transform = t }
        } else {
            transform = t
        }
    }
}
