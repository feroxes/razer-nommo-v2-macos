enum CLIRequest {
    case help
    case version
    case watch
    case device(CLICommand)

    init?(arguments: [String]) {
        switch arguments {
        case [CLIKeyword.help], [CLIKeyword.shortHelp]:
            self = .help
        case [CLIKeyword.version]:
            self = .version
        case [CLIKeyword.watch]:
            self = .watch
        default:
            guard let command = CLICommand(arguments: arguments) else { return nil }
            self = .device(command)
        }
    }
}
