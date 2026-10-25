import UIKit

/// The four picture styles a tile can show (used for the drawn icons).
enum GlyphKind { case heart, star, paw, smile }

/// Simple flat picture glyphs drawn in an 80 x 80 space.
final class GlyphView: UIView {
    var kind: GlyphKind { didSet { setNeedsDisplay() } }

    /// Creates the icon view. The background is clear so only the drawing shows, and taps pass
    /// through it.
    init(kind: GlyphKind) {
        self.kind = kind
        super.init(frame: .zero)
        backgroundColor = .clear
        isOpaque = false
        isUserInteractionEnabled = false
        isAccessibilityElement = false
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// UIKit calls this whenever the view needs to be painted. We scale an 80x80 drawing to fit the
    /// view, build the shape(s) for the chosen icon, fill them with semi-transparent white and
    /// outline them in dark ink.
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let s = bounds.width / 80
        ctx.scaleBy(x: s, y: s)

        var paths: [UIBezierPath] = []
        switch kind {
        case .heart:
            let p = UIBezierPath()
            p.move(to: CGPoint(x: 40, y: 66))
            p.addCurve(to: CGPoint(x: 30, y: 18), controlPoint1: CGPoint(x: 10, y: 44), controlPoint2: CGPoint(x: 12, y: 20))
            p.addCurve(to: CGPoint(x: 40, y: 24), controlPoint1: CGPoint(x: 36, y: 17), controlPoint2: CGPoint(x: 40, y: 21))
            p.addCurve(to: CGPoint(x: 50, y: 18), controlPoint1: CGPoint(x: 40, y: 21), controlPoint2: CGPoint(x: 44, y: 17))
            p.addCurve(to: CGPoint(x: 40, y: 66), controlPoint1: CGPoint(x: 68, y: 20), controlPoint2: CGPoint(x: 70, y: 44))
            p.close()
            paths = [p]
        case .star:
            let pts: [(CGFloat, CGFloat)] = [(40, 10), (49, 31), (72, 33), (54, 48), (60, 70),
                                              (40, 58), (20, 70), (26, 48), (8, 33), (31, 31)]
            let p = UIBezierPath()
            for (i, pt) in pts.enumerated() {
                let point = CGPoint(x: pt.0, y: pt.1)
                i == 0 ? p.move(to: point) : p.addLine(to: point)
            }
            p.close()
            paths = [p]
        case .paw:
            paths = [UIBezierPath(ovalIn: CGRect(x: 24, y: 39, width: 32, height: 26))]
            for c in [(20, 34), (34, 22), (48, 22), (62, 34)] {
                paths.append(UIBezierPath(ovalIn: CGRect(x: c.0 - 7, y: c.1 - 7, width: 14, height: 14)))
            }
        case .smile:
            paths = [UIBezierPath(ovalIn: CGRect(x: 12, y: 12, width: 56, height: 56))]
        }

        for p in paths {
            p.lineWidth = 4
            p.lineJoinStyle = .round
            p.lineCapStyle = .round
            UIColor.white.withAlphaComponent(0.55).setFill()
            p.fill()
            Palette.ink.setStroke()
            p.stroke()
        }

        if kind == .smile {
            Palette.ink.setFill()
            UIBezierPath(ovalIn: CGRect(x: 28, y: 31, width: 6, height: 6)).fill()
            UIBezierPath(ovalIn: CGRect(x: 46, y: 31, width: 6, height: 6)).fill()
            let mouth = UIBezierPath()
            mouth.move(to: CGPoint(x: 28, y: 46))
            mouth.addQuadCurve(to: CGPoint(x: 52, y: 46), controlPoint: CGPoint(x: 40, y: 60))
            mouth.lineWidth = 4
            mouth.lineCapStyle = .round
            Palette.ink.setStroke()
            mouth.stroke()
        }
    }
}
