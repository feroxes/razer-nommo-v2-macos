import Testing
@testable import NommoKit

@Suite("Monitor")
struct MonitorTests {
    @Test("Control interface is chosen by feature report size")
    func controlInterface() {
        #expect(DeviceMonitor.isControlInterface(maxFeatureReportSize: 90))
        #expect(DeviceMonitor.isControlInterface(maxFeatureReportSize: 91))
        #expect(!DeviceMonitor.isControlInterface(maxFeatureReportSize: 2))
    }
}
