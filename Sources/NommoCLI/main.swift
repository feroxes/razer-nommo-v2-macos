guard let request = CLIRequest(arguments: Array(CommandLine.arguments.dropFirst())) else {
    CLIProcess.fail(CLIOutput.usage)
}

switch request {
case .help:
    CLIProcess.succeed(printing: CLIOutput.usage)
case .version:
    CLIProcess.succeed(printing: CLIOutput.version(CLIVersion.current))
case .watch:
    SpeakerRunner.watch()
case .device(let command):
    SpeakerRunner.run(command)
}
