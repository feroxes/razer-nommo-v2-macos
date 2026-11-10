public enum LaunchAtLoginRenewal {
    public static func isNeeded(previousVersion: String?, currentVersion: String, isRequested: Bool) -> Bool {
        isRequested && previousVersion != currentVersion
    }
}
