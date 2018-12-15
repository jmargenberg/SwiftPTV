import Foundation

struct ErrorResponse: Codable {
    let message: String?
    let status: Status?
}
