import Foundation
import IOKit.hid

@MainActor
public final class DeviceMonitor {
    private static var runLoopMode: CFString {
        CFRunLoopMode.commonModes.rawValue
    }

    private let onConnect: @MainActor (NommoDevice) -> Void
    private let onDisconnect: @MainActor () -> Void
    private let manager: IOHIDManager
    private var activeDevice: IOHIDDevice?

    public init(onConnect: @escaping @MainActor (NommoDevice) -> Void, onDisconnect: @escaping @MainActor () -> Void) {
        self.onConnect = onConnect
        self.onDisconnect = onDisconnect
        self.manager = IOHIDManagerCreate(kCFAllocatorDefault, IOOptionBits(kIOHIDOptionsTypeNone))
    }

    nonisolated static func isControlInterface(maxFeatureReportSize: Int) -> Bool {
        maxFeatureReportSize >= HIDConstants.minimumControlFeatureReportSize
    }

    isolated deinit {
        stop()
    }

    func stop() {
        IOHIDManagerRegisterDeviceMatchingCallback(manager, nil, nil)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, nil, nil)
        IOHIDManagerUnscheduleFromRunLoop(manager, CFRunLoopGetMain(), Self.runLoopMode)
        closeActiveDevice()
    }

    public func reconnect() -> Bool {
        closeActiveDevice()
        let attached = IOHIDManagerCopyDevices(manager) as? Set<IOHIDDevice> ?? []
        attached.forEach(deviceAppeared)
        return activeDevice != nil
    }

    public func start() {
        let matching: [String: Int] = [
            kIOHIDVendorIDKey: HIDConstants.vendorID,
            kIOHIDProductIDKey: HIDConstants.productID
        ]
        IOHIDManagerSetDeviceMatching(manager, matching as CFDictionary)
        let context = Unmanaged.passUnretained(self).toOpaque()
        IOHIDManagerRegisterDeviceMatchingCallback(manager, { context, _, _, device in
            MainActor.assumeIsolated {
                DeviceMonitor.monitor(from: context)?.deviceAppeared(device)
            }
        }, context)
        IOHIDManagerRegisterDeviceRemovalCallback(manager, { context, _, _, device in
            MainActor.assumeIsolated {
                DeviceMonitor.monitor(from: context)?.deviceDisappeared(device)
            }
        }, context)
        IOHIDManagerScheduleWithRunLoop(manager, CFRunLoopGetMain(), Self.runLoopMode)
    }

    private static func monitor(from context: UnsafeMutableRawPointer?) -> DeviceMonitor? {
        guard let context else { return nil }
        return Unmanaged<DeviceMonitor>.fromOpaque(context).takeUnretainedValue()
    }

    private func deviceAppeared(_ device: IOHIDDevice) {
        guard isControlDevice(device), !isActive(device) else { return }
        guard IOHIDDeviceOpen(device, IOOptionBits(kIOHIDOptionsTypeNone)) == kIOReturnSuccess else { return }
        activeDevice = device
        onConnect(NommoDevice(transport: IOHIDTransport(device: device)))
    }

    private func deviceDisappeared(_ device: IOHIDDevice) {
        guard isActive(device) else { return }
        activeDevice = nil
        onDisconnect()
    }

    private func closeActiveDevice() {
        guard let activeDevice else { return }
        IOHIDDeviceClose(activeDevice, IOOptionBits(kIOHIDOptionsTypeNone))
        self.activeDevice = nil
    }

    private func isActive(_ device: IOHIDDevice) -> Bool {
        guard let activeDevice else { return false }
        return CFEqual(activeDevice, device)
    }

    private func isControlDevice(_ device: IOHIDDevice) -> Bool {
        let size = IOHIDDeviceGetProperty(device, kIOHIDMaxFeatureReportSizeKey as CFString) as? Int ?? HIDConstants.unknownFeatureReportSize
        return Self.isControlInterface(maxFeatureReportSize: size)
    }
}
