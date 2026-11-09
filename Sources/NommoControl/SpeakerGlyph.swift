import AppKit

enum SpeakerGlyph {
    private enum Geometry {
        static let canvas = NSSize(width: 22, height: 18)
        static let centersX: [CGFloat] = [5.5, 16.5]
        static let discCenterY: CGFloat = 6.5
        static let discRadius: CGFloat = 4
        static let driverRadius: CGFloat = 1.5
        static let lineWidth: CGFloat = 1.4
        static let baseY: CGFloat = 15.6
        static let baseHalfWidth: CGFloat = 2.6
    }

    static let image: NSImage = {
        let image = NSImage(size: Geometry.canvas, flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            draw(in: context)
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = Strings.title
        return image
    }()

    private static func draw(in context: CGContext) {
        context.setStrokeColor(NSColor.black.cgColor)
        context.setFillColor(NSColor.black.cgColor)
        context.setLineWidth(Geometry.lineWidth)
        context.setLineCap(.round)
        for centerX in Geometry.centersX {
            drawSpeaker(centeredAt: centerX, in: context)
        }
    }

    private static func drawSpeaker(centeredAt centerX: CGFloat, in context: CGContext) {
        let disc = circle(centerX: centerX, centerY: Geometry.discCenterY, radius: Geometry.discRadius)
        context.strokeEllipse(in: disc)
        context.move(to: CGPoint(x: centerX, y: disc.maxY + Geometry.lineWidth / 2))
        context.addLine(to: CGPoint(x: centerX, y: Geometry.baseY))
        context.move(to: CGPoint(x: centerX - Geometry.baseHalfWidth, y: Geometry.baseY))
        context.addLine(to: CGPoint(x: centerX + Geometry.baseHalfWidth, y: Geometry.baseY))
        context.strokePath()
        context.fillEllipse(in: circle(centerX: centerX, centerY: Geometry.discCenterY, radius: Geometry.driverRadius))
    }

    private static func circle(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) -> CGRect {
        CGRect(x: centerX - radius, y: centerY - radius, width: 2 * radius, height: 2 * radius)
    }
}
