# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.2.1] - 2026-11-11

### Fixed

- The saved lighting comes back after the speaker is switched off and on or reconnected over USB. The speaker resets its lighting to Spectrum during its first seconds on USB, so the app applies the color again 5 seconds after the speaker connects.

## [1.2.0] - 2026-11-10

### Added

- A rainbow button in place of the white swatch. It opens the macOS Colors window beside the panel, and the speaker follows the color as you pick it.

### Removed

- The White swatch. White is one click away in the Colors window.

## [1.1.0] - 2026-11-10

### Added

- About window with the version, the source code, the license and the Sparkle license.
- Check for Updates and in-app updates with Sparkle. Updates are signed, and a signed `appcast.xml` is published with each release.
- A dot on the menu-bar icon and a "Version X is available" row in the panel when an update is waiting; its Update… button opens Sparkle's window, where **Install Update** installs it.
- A ⋯ menu in the panel with About, Check for Updates…, Check Automatically, Donate and Quit.
- Auto power-off in the panel: a switch and a delay of 15, 30 or 45 minutes, read from the speaker and read back after each change.
- `nommo power [on|off|15|30|45]`; `nommo status` also prints auto power-off.

### Changed

- Quit moved from its own button into the ⋯ menu.
- Launch at login is registered again after an update.
- `CFBundleVersion` equals the version, as `CFBundleShortVersionString` does.
- The panel closes when another app becomes active.

## [1.0.0] - 2026-11-09

### Added

- Menu-bar app for the Razer Nommo V2 over USB, with a panel for the subwoofer, the equalizer and the lighting.
- Subwoofer level from 1 to 7.
- Equalizer presets Default, Game, Movie and Music, and a 10-band Custom curve that the app remembers.
- Spectrum and Static lighting with eight color swatches and brightness.
- Saved lighting is applied again whenever the speaker powers on.
- Automatic reconnect when the speaker switches off, comes back or stops answering.
- Launch at login.
- Liquid Glass panel on macOS 26 and later.
- `nommo` command-line tool with `status`, `sub`, `eq`, `light`, `brightness` and `watch`.
- Universal builds for Apple Silicon and Intel, running on macOS 14 and later.

[Unreleased]: https://github.com/feroxes/razer-nommo-v2-macos/compare/v1.2.1...HEAD
[1.2.1]: https://github.com/feroxes/razer-nommo-v2-macos/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/feroxes/razer-nommo-v2-macos/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/feroxes/razer-nommo-v2-macos/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/feroxes/razer-nommo-v2-macos/releases/tag/v1.0.0
