import UIKit

/// The first screen: logo, picture tiles, app name and the Get started button.
final class StartViewController: UIViewController {
    private let cluster = UIView()
    private let guide = UILayoutGuide()

    /// Creates the logo, tiles, texts and button, and positions them with Auto Layout. The tile
    /// cluster is centered in the space between the logo and the title.
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Palette.bg

        let logo = LogoView().prepared()

        let title = UILabel().prepared()
        title.text = "Nana App"
        title.font = Fonts.make(26, .medium, style: .title1)
        title.textColor = Palette.text
        title.numberOfLines = 0
        title.accessibilityTraits = .header

        let subtitle = UILabel().prepared()
        subtitle.text = "An interactive app made just for your babies."
        subtitle.font = Fonts.make(18)
        subtitle.textColor = Palette.muted
        subtitle.numberOfLines = 0

        let button = Buttons.make(title: "Get started", fill: Palette.primary, foreground: .white,
                                  height: 60, fontSize: 20)
        button.addTarget(self, action: #selector(getStarted), for: .touchUpInside)

        let privacy = UILabel().prepared()
        privacy.text = "Recordings stay on this phone. Nothing is uploaded."
        privacy.font = Fonts.make(13, style: .footnote)
        privacy.textColor = Palette.muted
        privacy.textAlignment = .center
        privacy.numberOfLines = 0

        cluster.prepared()
        buildCluster()

        view.addLayoutGuide(guide)
        [logo, cluster, title, subtitle, button, privacy].forEach(view.addSubview)

        let safe = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            logo.topAnchor.constraint(equalTo: safe.topAnchor, constant: 16),
            logo.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            logo.widthAnchor.constraint(equalToConstant: 84),
            logo.heightAnchor.constraint(equalToConstant: 84),

            privacy.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            privacy.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            privacy.bottomAnchor.constraint(equalTo: safe.bottomAnchor, constant: -12),

            button.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            button.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            button.bottomAnchor.constraint(equalTo: privacy.topAnchor, constant: -12),

            subtitle.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            subtitle.trailingAnchor.constraint(lessThanOrEqualTo: safe.trailingAnchor, constant: -24),
            subtitle.widthAnchor.constraint(lessThanOrEqualToConstant: 300),
            subtitle.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),

            title.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -24),
            title.bottomAnchor.constraint(equalTo: subtitle.topAnchor, constant: -10),

            guide.topAnchor.constraint(equalTo: logo.bottomAnchor),
            guide.bottomAnchor.constraint(equalTo: title.topAnchor),

            cluster.widthAnchor.constraint(equalToConstant: 342),
            cluster.heightAnchor.constraint(equalToConstant: 312),
            cluster.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cluster.centerYAnchor.constraint(equalTo: guide.centerYAnchor)
        ])
    }

    /// Draws the four colored picture tiles (heart, star, paw, smile) at fixed positions, plus a
    /// purple ring around the smiley.
    private func buildCluster() {
        let items: [(UIColor, GlyphKind, CGFloat, CGFloat, Bool)] = [
            (Palette.tile[3], .heart, 12, 0, false),
            (Palette.tile[0], .star, 198, 26, false),
            (Palette.tile[1], .paw, 30, 152, false),
            (Palette.tile[2], .smile, 206, 176, true)
        ]
        for (color, kind, x, y, ring) in items {
            let tile = UIView(frame: CGRect(x: x, y: y, width: 132, height: 132))
            tile.backgroundColor = color
            tile.layer.cornerRadius = 16
            let glyph = GlyphView(kind: kind)
            glyph.frame = CGRect(x: 31, y: 31, width: 70, height: 70)
            tile.addSubview(glyph)
            cluster.addSubview(tile)
            if ring {
                let r = UIView(frame: tile.frame.insetBy(dx: -9, dy: -9))
                r.layer.cornerRadius = 25
                r.layer.borderWidth = 4
                r.layer.borderColor = Palette.primary.cgColor
                r.isUserInteractionEnabled = false
                cluster.addSubview(r)
            }
        }
        cluster.isAccessibilityElement = false
    }

    /// Runs after the layout is calculated. On small screens it shrinks the tile cluster so it
    /// never overlaps the text.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let fitW = (view.bounds.width - 48) / 342
        let fitH = guide.layoutFrame.height / 312
        let s = max(0.3, min(1, fitW, fitH))
        cluster.transform = CGAffineTransform(scaleX: s, y: s)
    }

    /// Hides the navigation bar on this screen so it looks clean.
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    /// Called when "Get started" is tapped: moves to the Home screen.
    @objc private func getStarted() {
        navigationController?.pushViewController(HomeViewController(), animated: true)
    }
}
