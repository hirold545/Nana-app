import UIKit

/// App logo: a baby head inside a speech bubble, drawn in a 96 x 96 space.
final class LogoView: UIView {
    /// Sets up the logo view: transparent background, plus a description so VoiceOver can read the
    /// logo aloud.
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        isOpaque = false
        isAccessibilityElement = true
        accessibilityLabel = "Nana App logo: a baby head inside a speech bubble"
    }

    /// Required by UIKit for storyboard loading. We build everything in code, so this is never
    /// used.
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    /// Paints the logo: a purple speech bubble, then the baby face (head, ears, hair curl, eyes,
    /// smile, cheeks). Every point is on a 96x96 grid that is scaled to the view size.
    override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let s = bounds.width / 96
        ctx.scaleBy(x: s, y: s)

        let bubble = UIBezierPath()
        bubble.move(to: CGPoint(x: 32, y: 6))
        bubble.addLine(to: CGPoint(x: 64, y: 6))
        bubble.addCurve(to: CGPoint(x: 90, y: 32), controlPoint1: CGPoint(x: 79, y: 6), controlPoint2: CGPoint(x: 90, y: 17))
        bubble.addLine(to: CGPoint(x: 90, y: 48))
        bubble.addCurve(to: CGPoint(x: 64, y: 74), controlPoint1: CGPoint(x: 90, y: 63), controlPoint2: CGPoint(x: 79, y: 74))
        bubble.addLine(to: CGPoint(x: 42, y: 74))
        bubble.addLine(to: CGPoint(x: 18, y: 90))
        bubble.addLine(to: CGPoint(x: 24, y: 72))
        bubble.addCurve(to: CGPoint(x: 6, y: 48), controlPoint1: CGPoint(x: 13, y: 68), controlPoint2: CGPoint(x: 6, y: 59))
        bubble.addLine(to: CGPoint(x: 6, y: 32))
        bubble.addCurve(to: CGPoint(x: 32, y: 6), controlPoint1: CGPoint(x: 6, y: 17), controlPoint2: CGPoint(x: 17, y: 6))
        bubble.close()
        Palette.primary.setFill()
        bubble.fill()

        UIColor(hex: 0xFFD9B8).setFill()
        UIBezierPath(ovalIn: CGRect(x: 26, y: 18, width: 44, height: 44)).fill()
        UIBezierPath(ovalIn: CGRect(x: 22, y: 37.5, width: 9, height: 9)).fill()
        UIBezierPath(ovalIn: CGRect(x: 65, y: 37.5, width: 9, height: 9)).fill()

        let curl = UIBezierPath()
        curl.move(to: CGPoint(x: 48, y: 18))
        curl.addCurve(to: CGPoint(x: 59, y: 15), controlPoint1: CGPoint(x: 48, y: 11), controlPoint2: CGPoint(x: 57, y: 9))
        curl.lineWidth = 3.5
        curl.lineCapStyle = .round
        Palette.ink.setStroke()
        curl.stroke()

        Palette.ink.setFill()
        UIBezierPath(ovalIn: CGRect(x: 37.2, y: 35.2, width: 5.6, height: 5.6)).fill()
        UIBezierPath(ovalIn: CGRect(x: 53.2, y: 35.2, width: 5.6, height: 5.6)).fill()

        let smile = UIBezierPath()
        smile.move(to: CGPoint(x: 41, y: 48))
        smile.addQuadCurve(to: CGPoint(x: 55, y: 48), controlPoint: CGPoint(x: 48, y: 55))
        smile.lineWidth = 3.5
        smile.lineCapStyle = .round
        smile.stroke()

        UIColor(hex: 0xFF6FA5, alpha: 0.6).setFill()
        UIBezierPath(ovalIn: CGRect(x: 31.5, y: 43.5, width: 7, height: 7)).fill()
        UIBezierPath(ovalIn: CGRect(x: 57.5, y: 43.5, width: 7, height: 7)).fill()
    }
}
