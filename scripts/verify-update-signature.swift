import CryptoKit
import Foundation

enum ExitCode {
    static let invalid: Int32 = 1
    static let usage: Int32 = 2
}

enum Argument {
    static let count = 4
    static let file = 1
    static let signature = 2
    static let publicKey = 3
}

let arguments = CommandLine.arguments
guard arguments.count == Argument.count else {
    FileHandle.standardError.write(Data("usage: verify-update-signature.swift <file> <base64 signature> <base64 public key>\n".utf8))
    exit(ExitCode.usage)
}
guard let signature = Data(base64Encoded: arguments[Argument.signature]),
      let keyData = Data(base64Encoded: arguments[Argument.publicKey]),
      let publicKey = try? Curve25519.Signing.PublicKey(rawRepresentation: keyData),
      let contents = FileManager.default.contents(atPath: arguments[Argument.file]),
      publicKey.isValidSignature(signature, for: contents) else { exit(ExitCode.invalid) }
