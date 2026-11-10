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
        static let badgeCenter = CGPoint(x: 19.5, y: 2.5)
        static let badgeRadius: CGFloat = 2.5
        static let badgeGap: CGFloat = 1
    }

    static let image = makeImage(badged: false)
    static let badgedImage = makeImage(badged: true)

    private static func makeImage(badged: Bool) -> NSImage {
        let image = NSImage(size: Geometry.canvas, flipped: true) { _ in
            guard let context = NSGraphicsContext.current?.cgContext else { return false }
            draw(in: context)
            if badged {
                drawBadge(in: context)
            }
            return true
        }
        image.isTemplate = true
        image.accessibilityDescription = badged ? Strings.updateAvailableGlyph : Strings.title
        return image
    }

    private static func drawBadge(in context: CGContext) {
        let center = Geometry.badgeCenter
        context.setBlendMode(.clear)
        context.fillEllipse(in: circle(centerX: center.x, centerY: center.y, radius: Geometry.badgeRadius + Geometry.badgeGap))
        context.setBlendMode(.normal)
        context.fillEllipse(in: circle(centerX: center.x, centerY: center.y, radius: Geometry.badgeRadius))
    }

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
