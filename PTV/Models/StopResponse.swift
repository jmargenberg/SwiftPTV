import Foundation

struct StopResponse: Codable {
    let stops: [StopDetails]
    let status: Status
}
