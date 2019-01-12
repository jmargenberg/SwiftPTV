import Foundation

public struct StopsByDistanceResponse: Codable {
    public let stops: [StopGeosearch]
    public let status: Status
}
