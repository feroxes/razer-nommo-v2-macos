import Foundation

enum CLIProcess {
    private enum ExitCode {
        static let success = EXIT_SUCCESS
        static let failure = EXIT_FAILURE
    }

    static func succeed() -> Never {
        exit(ExitCode.success)
    }

    static func succeed(printing message: String) -> Never {
        print(message)
        succeed()
    }

    static func fail(_ message: String) -> Never {
        FileHandle.standardError.write(Data((message + CLIOutput.lineTerminator).utf8))
        exit(ExitCode.failure)
    }
}
