@testable import NommoKit

enum Fixture {
    static let musicBytes: [UInt8] = [0x0B, 0x0B, 0x0B, 0x09, 0x0C, 0x0F, 0x0E, 0x0C, 0x0E, 0x0C]
    static let musicGains = [-1, -1, -1, -3, 0, 3, 2, 0, 2, 0]
    static let unknownGains = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    static let customMode: UInt8 = 0x10
    static let builtInMode: UInt8 = 0x01
    static let subwooferByte: UInt8 = 0x02
    static let brightnessByte: UInt8 = 0xE5
    static let powerSavingOn: UInt8 = 0x01
    static let fifteenMinutes: [UInt8] = [0x03, 0x84]
    static let tint = LightColor(red: 0x12, green: 0x34, blue: 0x56)
    static let cyan = LightColor(red: 0x00, green: 0xFF, blue: 0xFF)
    static let violet = LightColor(red: 0xA0, green: 0x00, blue: 0xFF)
}
