import Foundation

public struct StopsOnRouteResponse: Codable {
    public let stops: [StopOnRoute]
    public let status: Status
}
