import UIKit

/// The "Let’s play" screen where you choose Family Soundboard or Games, and see what is coming
/// later.
final class HomeViewController: UIViewController {
    /// Builds the three cards and the footer, puts them in a scrolling vertical stack, and connects
    /// the taps.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg
        title = "Let’s play"

        let intro = UILabel()
        intro.text = "Pick something to do together."
        intro.font = Fonts.make(17)
        intro.textColor = Palette.muted

        let soundboard = CardControl(color: Palette.tile[3], glyph: .heart, symbol: nil,
                                     title: "Family Soundboard", subtitle: "Tap a picture to hear family voices.")
        soundboard.addTarget(self, action: #selector(openBoard), for: .touchUpInside)

        let games = CardControl(color: Palette.tile[0], glyph: .star, symbol: nil,
                                title: "Games", subtitle: "Shapes, letters, words and more.")
        games.addTarget(self, action: #selector(openGames), for: .touchUpInside)

        let more = CardControl(color: nil, glyph: nil, symbol: "sparkles",
                               title: "More to come", subtitle: "New ideas will show up here.",
                               chip: "Coming soon")

        let footer = UILabel()
        footer.text = "Everything stays on this phone. Nothing is uploaded."
        footer.font = Fonts.make(13, style: .footnote)
        footer.textColor = Palette.muted
        footer.textAlignment = .center
        footer.numberOfLines = 0

        let stack = UIStackView(arrangedSubviews: [intro, soundboard, games, more, footer])
        stack.axis = .vertical
        stack.spacing = 14
        stack.setCustomSpacing(20, after: more)
        stack.prepared()

        let scroll = UIScrollView().prepared()
        view.addSubview(scroll)
        scroll.addSubview(stack)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -24),
            stack.leadingAnchor.constraint(equalTo: scroll.frameLayoutGuide.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: scroll.frameLayoutGuide.trailingAnchor, constant: -20)
        ])
    }

    /// Shows the navigation bar again (the Start screen hides it).
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    /// Opens the Family Soundboard screen.
    @objc private func openBoard() {
        navigationController?.pushViewController(BoardViewController(), animated: true)
    }

    /// Games are not built yet, so show a friendly "coming soon" message.
    @objc private func openGames() {
        let alert = UIAlertController(title: "Games are coming soon", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: true)
    }
}
