import Foundation

enum CLIVersion {
    private static let shortVersionKey = "CFBundleShortVersionString"

    static var current: String? {
        Bundle.main.object(forInfoDictionaryKey: shortVersionKey) as? String
    }
}
