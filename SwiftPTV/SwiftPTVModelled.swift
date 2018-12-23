import UIKit
import CoreLocation

/**
 Adapts most methods of the PTV RESTful API, decoding all json responses and returning cadables.
 
 Most of the responses are encoded into simple Codable Structs described in the 'Models' group but some structs such as Departure and StoppingPattern also include useful functions.
 
 ## PTV Stops
 The PTV API provides 3 different types of Stops, each holding slightly different information:
 - StopGeosearch - getStops(nearLocation:  forRouteTypes: maxResults: maxDistance: completion: ) - all stops near a given location
 - StopOnRoute - getStops(onRoute: forRouteType: completion: ) - all the stops for a given route
 - StopDetails - getStopDetails(forStop: forRouteType: completion: ) - detailed description of stop including amenities
 */
class SwiftPTVModelled: SwiftPTV {
    
    public static let TRAIN_ROUTE_TYPE = 0 // RouteTypeId for Train Service
    
    override init(devid: String, key: String, urlSession: URLSession = URLSession.shared) {
        super.init(devid: devid, key: key, urlSession: urlSession)
    }
    
    
    // MARK: - Standard API request functions
    
    public func getRouteTypes(failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routeTypes: [RouteType]) -> ()) {
        self.call(apiName: "route_types", searchString: "", params: nil, decodeTo: RouteTypesResponse.self, failure: failure) { (routeTypesResponse) in
            completion(routeTypesResponse.route_types)
        }
    }
    
    private func getRoutes(params: [String: String], failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        self.call(apiName: "routes", searchString: "", params: params, decodeTo: RoutesResponse.self, failure: failure) { (routesResponse) in
            completion(routesResponse.routes)
        }
    }
    
    public func getRoutes(failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        self.call(apiName: "routes", searchString: "", params: nil, decodeTo: RoutesResponse.self, failure: failure) { (routesResponse) in
            completion(routesResponse.routes)
        }
    }
    
    public func getRoutes(forRouteTypeID routeTypeID: Int, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        self.getRoutes(failure: failure) { (routes) in
            completion(routes.filter({ $0.route_type == routeTypeID }))
        }
    }
    
    public func getRoutes(forRouteTypeIDs routeTypeIDs: [Int], failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        let routeTypesStrings = routeTypeIDs.map { (id) -> String in String(id)}
        let routeTypesEncoded = routeTypesStrings.joined(separator: ",")
        
        self.getRoutes(params: ["route_types": routeTypesEncoded], failure: failure, completion: completion)
    }
    
    public func getStops(nearLocation location: CLLocationCoordinate2D, forRouteTypes routeTypes: [Int] = [SwiftPTVCached.TRAIN_ROUTE_TYPE], maxResults: Int = 1000, maxDistance: Int = 5000, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (([StopGeosearch]) -> ())) {
        let searchString = "\(String(location.latitude)),\(String(location.longitude))"
        let params = [
            "route_types": (routeTypes.map {(type) -> String in String(type)}).joined(separator: ","),
            "max_results": String(maxResults),
            "max_distance": String(maxDistance)
        ]
        
        self.call(apiName: "stops/location", searchString: searchString, params: params, decodeTo: StopsByDistanceResponse.self, failure: failure) { (stopsGeosearchResponse) in
            completion(stopsGeosearchResponse.stops)
        }
    }
    
    public func getStops(onRoute routeId: Int, forRouteType routeTypeId: Int = SwiftPTVCached.TRAIN_ROUTE_TYPE, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (([StopOnRoute]) -> ())) {
        let searchString = "route/\(routeId)/route_type/\(routeTypeId)"
        
        self.call(apiName: "stops", searchString: searchString, params: nil, decodeTo: StopsOnRouteResponse.self, failure: failure) { (stopsOnRouteResponse) in
            completion(stopsOnRouteResponse.stops)
        }
    }
    
    public func getStopDetails(forStop stopId: Int, forRouteType routeTypeId: Int = SwiftPTVCached.TRAIN_ROUTE_TYPE, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping ((StopDetails) -> ())) {
        let searchString = "\(String(stopId))/route_type/\(String(routeTypeId))"
        let params = [
            "stop_amenities": "true",
            "stop_accessibility": "true"
        ]
        
        self.call(apiName: "stops", searchString: searchString, params: params, decodeTo: StopDetailsResponse.self, failure: failure) { (StopDetailsResponse) in
            completion(StopDetailsResponse.stop)
        }
    }
    
    public func getDeparture(forStop stopId: Int, withRouteType routeTypeId: Int, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (([Departure]) -> ())) {
        let searchString = "route_type/\(String(routeTypeId))/stop/\(String(stopId))"
        let params = ["expand": "all"]
        
        self.call(apiName: "departures", searchString: searchString, params: params, decodeTo: DeparturesResponse.self, failure: failure) { (departuresResponse) in
            completion(departuresResponse.departures)
        }
    }
    
    public func getStoppingPattern(forRun runId: Int, withRouteType routeTypeId: Int, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (StoppingPattern) -> ()) {
        let searchString = "run/\(String(runId))/route_type/\(routeTypeId)"
        
        self.call(apiName: "pattern", searchString: searchString, params: nil, decodeTo: StoppingPattern.self, failure: failure, completion: completion)
    }
}
