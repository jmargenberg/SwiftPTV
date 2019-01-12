import Foundation

public struct RouteTypesResponse: Codable {
    public let route_types: [RouteType]
    public let status: Status
}
