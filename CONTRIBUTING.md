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
3. The release workflow runs the tests, builds both zips, checks that the app and `nommo --version` report the tag's version, writes `SHA256SUMS.txt` and `appcast.xml`, and publishes a GitHub Release with both zips, the checksums, the appcast and that version's changelog section as its notes. A tag with a hyphen, such as `v1.1.0-beta`, is published as a pre-release.

Both versions come from the tag through `git describe`: `scripts/build-app.sh` writes it into the app's `Info.plist` (as `CFBundleShortVersionString` and `CFBundleVersion`) and embeds it in the `nommo` binary, so neither `Resources/Info.plist` nor the code needs editing.

### Signing keys for updates

Updates are signed with an EdDSA key. Generate the key pair once for the project, with the Sparkle tools that `swift build` leaves in `.build/arch/arm64/artifacts/sparkle/Sparkle/bin/` after `scripts/build-app.sh`:

1. Run `generate_keys` once, on one Mac. It stores the private key in your login Keychain and prints the public key. That public key is the value of `SUPublicEDKey` in `Resources/Info.plist`.
2. Run `generate_keys -x <file>` to export the private key to a file.
3. Run `gh secret set SPARKLE_PRIVATE_KEY < <file>` to store it as the repository secret the release workflow reads.
4. Back the key up in a password manager and delete the exported file.

`SUPublicEDKey` must never change after a release, because installed apps verify updates against the key they shipped with. On another Mac, import the existing private key with `generate_keys -f <file>` and check it with `generate_keys -p`; never run plain `generate_keys` there and paste a new public key. The release workflow refuses a key that differs from the previous stable release's.

If the key is lost, existing users can no longer update from inside the app; they have to download a new release by hand.

### What the release workflow checks

- The tests pass.
- Both binaries contain arm64 and x86_64 slices and record SDK 26 or later.
- The app passes `scripts/check-app.sh`: valid code signature, embedded Sparkle, the `Frameworks` rpath, an `https://` feed URL and a public key, automatic installs and system profiling off, no `SUEnableAutomaticChecks`, and `CFBundleVersion` equal to the version.
- The app's version and `nommo --version` equal the tag.
- The appcast has exactly one item, with the tag's version, a download URL under the tag's release and an EdDSA signature, and that signature verifies against the `SUPublicEDKey` in the zipped app.
- The `SUPublicEDKey` in the zipped app equals the one in the newest earlier stable tag (a tag without a hyphen), when that tag has one.

### Testing an update locally

1. Build an older and a newer version, for example `NOMMO_VERSION=1.0.1 scripts/build-app.sh` and then `NOMMO_VERSION=1.0.2 scripts/build-app.sh`. Keep a copy of each zip and app, because every build replaces `build/`.
2. Write an appcast for the newer zip with `generate_appcast --ed-key-file <file> --download-url-prefix http://127.0.0.1:8000/ <folder>`, where `<folder>` holds only the newer zip, and serve that folder with `python3 -m http.server`. Use the key you exported and delete it afterwards.
3. Point the older app at that feed: `defaults write io.github.feroxes.NommoControl SUFeedURL http://127.0.0.1:8000/appcast.xml`. Sparkle reads this value before `Info.plist`.
4. Open the older app and choose **Check for Updates…**.
5. Restore the real feed: `defaults delete io.github.feroxes.NommoControl SUFeedURL`.

Test builds share the bundle id and the defaults of the real app, so afterwards relaunch the real app from `/Applications` to point Launch at login at it again.
