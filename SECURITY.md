# Security policy

## Supported versions

Security fixes go into the latest release only.

## Updates

Updates are signed with an EdDSA key. The public key is `SUPublicEDKey` in [`Resources/Info.plist`](Resources/Info.plist), and the app installs an update only if its signature matches that key. The release workflow checks each appcast signature against the key inside the shipped app before it publishes the release. If you suspect the signing key has been compromised, report it privately, as described below.

## Reporting a vulnerability

Please don't report security problems in public issues, discussions or pull requests. Report them privately through GitHub instead:

1. Open the [Security tab](https://github.com/feroxes/razer-nommo-v2-macos/security) of this repository.
2. Click **Report a vulnerability**. This opens a private security advisory that only you and the maintainer can see.
3. Describe the problem, how to reproduce it, and the versions of Nommo Control and macOS you used.

The maintainer replies in the advisory. When a fix is released, the advisory is published with credit to you, unless you'd rather stay anonymous.
