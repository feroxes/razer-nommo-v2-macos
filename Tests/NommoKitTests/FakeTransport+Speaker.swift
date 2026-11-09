@testable import NommoKit

extension FakeTransport {
    static func speaker(subwoofer: UInt8, equalizerMode: UInt8, curve: [UInt8], brightness: UInt8) -> FakeTransport {
        let padding = CommandCode.zeroByte
        return FakeTransport(memory: [
            CommandCode.audioClass: [
                CommandCode.readSubwooferID: [padding, subwoofer],
                CommandCode.readEqualizerModeID: [padding, equalizerMode],
                CommandCode.readEqualizerCurveID: [padding] + curve
            ],
            CommandCode.lightingClass: [
                CommandCode.readBrightnessID: [padding, padding, brightness]
            ]
        ])
    }
}
