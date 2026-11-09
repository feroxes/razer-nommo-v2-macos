import AppKit

enum Canvas {
    static let size: CGFloat = 1024
    static let tileInset: CGFloat = 100
    static let tileCornerRadius: CGFloat = 185
}

enum Palette {
    static let tileTop = NSColor(srgbRed: 0x1B / 255, green: 0x2A / 255, blue: 0x4D / 255, alpha: 1)
    static let tileBottom = NSColor(srgbRed: 0x0F / 255, green: 0x1A / 255, blue: 0x33 / 255, alpha: 1)
    static let line = NSColor.white
    static let driver = NSColor(srgbRed: 0x4C / 255, green: 0xC9 / 255, blue: 0xF0 / 255, alpha: 1)
}

enum Speaker {
    static let offset: CGFloat = 150
    static let discCenterY: CGFloat = 440
    static let discRadius: CGFloat = 118
    static let driverRadius: CGFloat = 44
    static let lineWidth: CGFloat = 34
    static let baseY: CGFloat = 712
    static let baseHalfWidth: CGFloat = 78
}

func drawIcon(in context: CGContext) {
    let size = Canvas.size
    let tile = CGRect(x: Canvas.tileInset, y: Canvas.tileInset, width: size - 2 * Canvas.tileInset, height: size - 2 * Canvas.tileInset)
    let tilePath = CGPath(roundedRect: tile, cornerWidth: Canvas.tileCornerRadius, cornerHeight: Canvas.tileCornerRadius, transform: nil)
    context.saveGState()
    context.addPath(tilePath)
    context.clip()
    let colors = [Palette.tileTop.cgColor, Palette.tileBottom.cgColor] as CFArray
    if let gradient = CGGradient(colorsSpace: CGColorSpace(name: CGColorSpace.sRGB), colors: colors, locations: [0, 1]) {
        context.drawLinearGradient(gradient, start: CGPoint(x: 0, y: tile.minY), end: CGPoint(x: 0, y: tile.maxY), options: [])
    }
    context.restoreGState()

    context.setLineWidth(Speaker.lineWidth)
    context.setLineCap(.round)
    for direction in [-1.0, 1.0] {
        let centerX = size / 2 + direction * Speaker.offset
        let disc = CGPoint(x: centerX, y: Speaker.discCenterY)
        context.setStrokeColor(Palette.line.cgColor)
        context.strokeEllipse(in: CGRect(x: disc.x - Speaker.discRadius, y: disc.y - Speaker.discRadius, width: 2 * Speaker.discRadius, height: 2 * Speaker.discRadius))
        context.move(to: CGPoint(x: centerX, y: disc.y + Speaker.discRadius + Speaker.lineWidth / 2))
        context.addLine(to: CGPoint(x: centerX, y: Speaker.baseY))
        context.move(to: CGPoint(x: centerX - Speaker.baseHalfWidth, y: Speaker.baseY))
        context.addLine(to: CGPoint(x: centerX + Speaker.baseHalfWidth, y: Speaker.baseY))
        context.strokePath()
        context.setFillColor(Palette.driver.cgColor)
        context.fillEllipse(in: CGRect(x: disc.x - Speaker.driverRadius, y: disc.y - Speaker.driverRadius, width: 2 * Speaker.driverRadius, height: 2 * Speaker.driverRadius))
    }
}

let pixels = Int(Canvas.size)
guard let rep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: pixels, pixelsHigh: pixels, bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: .deviceRGB, bytesPerRow: 0, bitsPerPixel: 0),
      let graphics = NSGraphicsContext(bitmapImageRep: rep) else { exit(1) }
let context = graphics.cgContext
context.translateBy(x: 0, y: Canvas.size)
context.scaleBy(x: 1, y: -1)
drawIcon(in: context)
graphics.flushGraphics()
let output = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon-1024.png"
guard let data = rep.representation(using: .png, properties: [:]) else { exit(1) }
try data.write(to: URL(fileURLWithPath: output))
print(output)
