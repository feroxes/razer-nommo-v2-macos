import Testing
@testable import NommoKit

@Suite("Launch at login renewal")
struct LaunchAtLoginRenewalTests {
    @Test("Renews after a version change only when requested", arguments: [
        (nil as String?, "1.1.0", true, true),
        ("1.0.0", "1.1.0", true, true),
        ("1.1.0", "1.1.0", true, false),
        ("1.0.0", "1.1.0", false, false),
        (nil as String?, "1.1.0", false, false)
    ])
    func renewal(previous: String?, current: String, requested: Bool, expected: Bool) {
        #expect(LaunchAtLoginRenewal.isNeeded(previousVersion: previous, currentVersion: current, isRequested: requested) == expected)
    }

    @Test("Launch records persist and start empty")
    func launchRecords() {
        let store = SettingsStore(defaults: InMemoryDefaults())
        #expect(store.launchAtLoginRequested == nil)
        #expect(store.lastLaunchedVersion == nil)
        store.launchAtLoginRequested = true
        store.lastLaunchedVersion = "1.1.0"
        let reloaded = SettingsStore(defaults: store.defaults)
        #expect(reloaded.launchAtLoginRequested == true)
        #expect(reloaded.lastLaunchedVersion == "1.1.0")
    }
}
