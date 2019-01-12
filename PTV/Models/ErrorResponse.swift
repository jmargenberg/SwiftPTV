import Foundation

public struct ErrorResponse: Codable {
    let message: String
    let status: Status
}
