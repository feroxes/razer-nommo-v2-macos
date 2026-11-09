protocol ReportTransport: AnyObject {
    func exchange(_ request: [UInt8]) throws -> [UInt8]
}
