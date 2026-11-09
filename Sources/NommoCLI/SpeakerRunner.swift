import Foundation
import NommoKit

@MainActor
enum SpeakerRunner {
    private enum Timing {
        static let connectTimeout: TimeInterval = 3
        static let runLoopSlice: TimeInterval = 0.05
    }

    static func run(_ command: CLICommand) -> Never {
        var connected: NommoDevice?
        let monitor = DeviceMonitor(onConnect: { connected = $0 }, onDisconnect: {})
        withExtendedLifetime(monitor) { () -> Never in
            monitor.start()
            let deadline = Date().addingTimeInterval(Timing.connectTimeout)
            while connected == nil && Date() < deadline {
                CFRunLoopRunInMode(.defaultMode, Timing.runLoopSlice, false)
            }
            guard let device = connected else { CLIProcess.fail(CLIOutput.speakerNotFound) }
            do {
                CLIProcess.succeed(printing: try command.run(on: device))
            } catch {
                CLIProcess.fail(CLIOutput.failure(error))
            }
        }
    }

    static func watch() -> Never {
        let monitor = DeviceMonitor(
            onConnect: { device in
                let line = (try? CLICommand.status.run(on: device)) ?? CLIOutput.unknown
                print(CLIOutput.connectedPrefix + line)
                fflush(stdout)
            },
            onDisconnect: {
                print(CLIOutput.disconnected)
                fflush(stdout)
            }
        )
        withExtendedLifetime(monitor) {
            monitor.start()
            CFRunLoopRun()
        }
        CLIProcess.succeed()
    }
}
