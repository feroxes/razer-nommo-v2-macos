public enum SpeakerError: Error, Equatable {
    case transport(Int32)
    case noReply
    case unexpectedReply
}
