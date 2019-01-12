import Foundation

public struct StopResponse: Codable {
    let stops: [StopDetails]
    let status: Status
}
