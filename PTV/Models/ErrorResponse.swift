import Foundation

public struct ErrorResponse: Codable {
    public let message: String
    public let status: Status
}
