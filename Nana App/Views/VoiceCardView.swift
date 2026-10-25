import UIKit

/// The voice box in the editor: a status line, a bar "waveform", and Record / Play buttons.
/// It only draws what it is told (see render) and reports button taps. It never records itself.
final class VoiceCardView: UIView {
    /// Called when the Record / Stop button is tapped.
    var onRecord: (() -> Void)?
    /// Called when the Play button is tapped.
    var onPlay: (() -> Void)?

    private let statusLabel = UILabel()
    private let timeLabel = UILabel()
    private var bars: [UIView] = []
    private var recordButton: UIButton!
    private var playButton: UIButton!
    private let barHeights: [CGFloat] = [14, 26, 38, 22, 44, 30, 50, 34, 20, 42, 28, 48, 24, 36, 18, 30, 12]

    /// Builds the card: rounded background, header row, bars and the two buttons.
    init() {
        super.init(frame: .zero)
        backgroundColor = Palette.surface
        layer.cornerRadius = 16

        statusLabel.font = Fonts.make(16, .medium)
        timeLabel.font = Fonts.make(14)
        timeLabel.textColor = Palette.muted
        timeLabel.textAlignment = .right
        let header = UIStackView(arrangedSubviews: [statusLabel, timeLabel])

        let barRow = UIStackView()
        barRow.distribution = .equalSpacing
        barRow.alignment = .center
        for h in barHeights {
            let b = UIView()
            b.layer.cornerRadius = 3
            b.widthAnchor.constraint(equalToConstant: 6).isActive = true
            b.heightAnchor.constraint(equalToConstant: h).isActive = true
            bars.append(b)
            barRow.addArrangedSubview(b)
        }
        barRow.heightAnchor.constraint(equalToConstant: 50).isActive = true
        barRow.isAccessibilityElement = false

        recordButton = Buttons.make(title: "Record", icon: "mic.fill", fill: Palette.danger, foreground: .white)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        playButton = Buttons.make(title: "Play", fill: nil, foreground: Palette.primary, stroke: Palette.primary)
        playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
        let buttons = UIStackView(arrangedSubviews: [recordButton, playButton])
        buttons.spacing = 10
        buttons.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [header, barRow, buttons])
        stack.axis = .vertical
        stack.spacing = 12
        stack.prepared()
        addSubview(stack)
        stack.pin(to: self, insets: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Updates the card from the current state: status text, timer, bar colors, button labels,
    /// and whether Play is allowed (only when a voice exists and we are not recording).
    func render(isRecording: Bool, hasAudio: Bool, seconds: Int) {
        statusLabel.text = isRecording ? "Recording…" : (hasAudio ? "Recorded" : "No voice yet")
        statusLabel.textColor = isRecording ? Palette.danger : Palette.text
        timeLabel.text = isRecording ? String(format: "0:%02d of 0:10", seconds) : "up to 10 seconds"

        let barColor = isRecording ? Palette.danger : (hasAudio ? Palette.primary : Palette.outline.withAlphaComponent(0.4))
        bars.forEach { $0.backgroundColor = barColor }

        var config = recordButton.configuration
        config?.title = isRecording ? "Stop" : (hasAudio ? "Record again" : "Record")
        config?.image = UIImage(systemName: isRecording ? "stop.fill" : "mic.fill")
        recordButton.configuration = config

        let canPlay = hasAudio && !isRecording
        playButton.isEnabled = canPlay
        playButton.alpha = canPlay ? 1 : 0.4
    }

    /// Tells the controller that Record / Stop was tapped.
    @objc private func recordTapped() { onRecord?() }

    /// Tells the controller that Play was tapped.
    @objc private func playTapped() { onPlay?() }
}
