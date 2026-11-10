import AppKit

enum AboutPanel {
    private static let emptyBuildVersion = ""
    private static let lineBreak = "\n"
    private static let sparkleLicenseName = "Sparkle-LICENSE"
    private static let sparkleLicenseExtension = "txt"
    private static let links: [(title: String, url: URL?)] = [
        (Strings.sourceCode, ProjectLinks.repository),
        (Strings.license, ProjectLinks.license),
        (Strings.updatesBySparkle, ProjectLinks.sparkle),
        (Strings.sparkleLicense, Bundle.main.url(forResource: sparkleLicenseName, withExtension: sparkleLicenseExtension)),
    ]

    @MainActor
    static func show() {
        NSApp.activate()
        NSApp.orderFrontStandardAboutPanel(options: [
            .version: emptyBuildVersion,
            .credits: credits,
        ])
    }

    private static var credits: NSAttributedString {
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let base: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: NSFont.smallSystemFontSize),
            .paragraphStyle: paragraph,
        ]
        var textAttributes = base
        textAttributes[.foregroundColor] = NSColor.labelColor
        let result = NSMutableAttributedString(string: Strings.disclaimer, attributes: textAttributes)
        for link in links {
            result.append(NSAttributedString(string: lineBreak, attributes: textAttributes))
            var attributes = base
            attributes[.link] = link.url
            result.append(NSAttributedString(string: link.title, attributes: attributes))
        }
        return result
    }
}
