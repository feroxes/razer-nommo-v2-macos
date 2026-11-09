import Foundation

enum AppIdentifier {
    private static let fallbackBundle = "io.github.feroxes.NommoControl"
    private static let separator = "."

    static let bundle = Bundle.main.bundleIdentifier ?? fallbackBundle

    static func qualified(_ name: String) -> String {
        bundle + separator + name
    }
}
