import Foundation

public struct StopResponse: Codable {
    public let stops: [StopDetails]
    public let status: Status
}
