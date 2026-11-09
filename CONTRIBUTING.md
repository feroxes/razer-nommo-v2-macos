# Contributing

Thanks for helping to improve Nommo Control. Bug reports, fixes and support for more speaker models are all welcome. For larger changes, please open an issue first so we can agree on the approach. Report security problems privately, as described in [SECURITY.md](SECURITY.md).

## Setup

You need Xcode 26 or later, or Command Line Tools with Swift 6.2 or later. The tests don't need a speaker; trying a change on real hardware needs a Nommo V2 connected over USB.

```sh
swift build
swift test
swift run nommo status
scripts/build-app.sh
```

`scripts/build-app.sh` creates `build/Nommo Control.app`, which you can open to try the app.

### `swift test` with Command Line Tools

With Command Line Tools and no Xcode, `swift test` sometimes fails to compile the tests with an error like this:

```text
external macro implementation type 'TestingMacros.…' could not be found … plugin for module 'TestingMacros' not found
```

The toolchain doesn't always pass the swift-testing macro plugin to the compiler. Point the compiler at it yourself:

```sh
swift test -Xswiftc -plugin-path -Xswiftc /Library/Developer/CommandLineTools/usr/lib/swift/host/plugins/testing
```

Xcode toolchains, including the one in CI, don't need this.

### No SwiftUI macros

Command Line Tools don't include the SwiftUI macro plugins, so `@State`, `#Preview` and other SwiftUI macros don't compile there. Keep state in `SpeakerModel`, which is an `@Observable` class, and pass bindings to views, as the existing views do. The app's entry point is AppKit for the same reason.

## Code conventions

- **No comments in code.** Names and small types should explain the code. Longer explanations belong in `docs/` or in the pull request.
- **No magic numbers or strings.** Give every literal a name, usually in a private enum inside the type (`Layout`, `Symbol`, `Timing`) or in a shared one such as `CommandCode`, `PacketLayout` or `HIDConstants`.
- **Small files with one responsibility.** A new type gets its own file.
- **English identifiers.** UI text lives in `Sources/NommoControl/Strings.swift`, CLI text in `Sources/NommoCLI/CLIOutput.swift`.
- **Swift API Design Guidelines.** For example, device setters are named `write…`, and initializers that clamp their input are `init(clamping:)`.
- **Swift 6 language mode with no warnings from our code.** Keep wire-level types internal to `NommoKit`, and make something public only when the app or the CLI needs it.
- Indent with four spaces. [`.editorconfig`](.editorconfig) has the details.

## Tests

- Tests use swift-testing: `import Testing`, one `@Suite` per area, `@Test("…")` with a readable description, `#expect` and `#require`.
- Use `@testable import NommoKit` to reach internal types.
- Test device behavior with `FakeTransport` and settings with `InMemoryDefaults`. Tests never talk to real hardware.
- Changes to `NommoKit` come with tests.

## Speaker safety

The speaker's protocol is undocumented, and unknown commands can have unknown effects.

- Send only the commands listed in [docs/PROTOCOL.md](docs/PROTOCOL.md).
- If you find a new command, explain in the pull request how you verified it on a real speaker, and add it to `docs/PROTOCOL.md`.
- Supporting another model, such as the Nommo V2 Pro or V2 X, needs its USB product ID and testing on that model.

## Pull requests

- Branch from `main` and target `main`.
- `swift build`, `swift test` and `scripts/build-app.sh` must succeed. CI runs the same steps.
- Write commit messages as one line that states the change.
- Add user-visible changes to [CHANGELOG.md](CHANGELOG.md) under "Unreleased".
- Include a screenshot for UI changes.

## Releasing

For maintainers:

1. In `CHANGELOG.md`, move the "Unreleased" entries into a new version section with today's date, and update the links at the bottom.
2. Commit, then create and push the tag, for example `git tag v1.0.0` and `git push origin v1.0.0`.
3. The release workflow runs the tests, builds both zips, checks that the app and `nommo --version` report the tag's version, writes `SHA256SUMS.txt` and publishes a GitHub Release with that version's changelog section as its notes. A tag with a hyphen, such as `v1.1.0-beta`, is published as a pre-release.

Both versions come from the tag through `git describe`: `scripts/build-app.sh` writes it into the app's `Info.plist` and embeds it in the `nommo` binary, so neither `Resources/Info.plist` nor the code needs editing.
