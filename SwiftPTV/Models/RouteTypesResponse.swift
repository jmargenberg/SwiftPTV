import Foundation

struct RouteTypesResponse: Codable {
    let route_types: [RouteType]
    let status: Status?
}
