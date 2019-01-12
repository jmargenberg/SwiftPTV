import Foundation

public struct RoutesResponse: Codable {
    public let routes: [Route] // NOTE: spec actually states a single route, but actually returns list of routes
    public let status: Status
}
