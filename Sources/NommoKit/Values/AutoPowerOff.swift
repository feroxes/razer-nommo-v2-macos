public struct AutoPowerOff: Equatable, Sendable {
    public let isEnabled: Bool
    public let delay: PowerOffDelay?

    public init(isEnabled: Bool, delay: PowerOffDelay?) {
        self.isEnabled = isEnabled
        self.delay = delay
    }
}
