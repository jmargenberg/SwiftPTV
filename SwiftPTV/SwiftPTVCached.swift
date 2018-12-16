import UIKit
import CoreLocation

/**
 Adapts most methods of the PTV RESTful API, decoding all json responses and returning structs, whilst caching (most) encountered objects for cheap retrieval at a later time.
 
 Most of the responses are encoded into simple Codable Structs described in the 'Models' group but some such as Departure and StoppingPattern also include useful functions.
 
 Essentially all objects returned that are likely to be 'static' (not change between calls) are stored in a cache accessed by a method get[ObjectName]FromCache(where[ObjectName]Id[id])
 Cached Objects:
 - RouteType
 - StopGeosearch (although .distance should be ignore if retrieved from cache)
 - Route
 - Run
 - Direction
 - StopsOnRoute
 Non-cached Objects:
 - Departure
 
 Non-cached requests pass results to completion closures, Cached requests use standard return types.
 
 All non-cached request arguments conform closely to the associated parameter list at https://timetableapi.ptv.vic.gov.au/swagger/ui/index
 
 The PTV API provides 3 different types of Stops, each holding slightly different information:
 - StopGeosearch - getStops(nearLocation:  forRouteTypes: maxResults: maxDistance: completion: ) - all stops near a given location
 - StopOnRoute - getStops(onRoute: forRouteType: completion: ) - all the stops for a given route
 - StopDetails - getStopDetails(forStop: forRouteType: completion: ) - detailed description of stop including amenities
 */
class SwiftPTVCached: SwiftPTV {
    
    public static let TRAIN_ROUTE_TYPE = 0 // RouteTypeId for Train Service
    
    private var cachedRouteTypes: [RouteType]
    // private var routesCache: [Route] // route_type
    private var cachedStopsGeosearch: [Int: StopGeosearch] // StopGeosearch objects (not StopDetails, or StopOnRoute) indexed by their StopID
    private var cachedRoutes: [Int: Route] // Route objects indexed by their routeID
    private var cachedRuns: [Int: Run] // Run objects indexed by their runID
    private var cachedDirections: [Int: Direction] // Direction objects indexed by their directionID
    private var cachedStopsOnRoute: [Int: StopOnRoute] // StopOnRoute objects (not StopGeosearch or StopDetails) indexed by their StopId
    
    override init(devid: String, key: String, urlSession: URLSession = URLSession.shared) {
        // initalise cache
        self.cachedRouteTypes = []
        self.cachedRoutes = [:]
        self.cachedStopsGeosearch = [:]
        self.cachedRoutes = [:]
        self.cachedRuns = [:]
        self.cachedDirections = [:]
        self.cachedStopsOnRoute = [:]
        
        super.init(devid: devid, key: key, urlSession: urlSession)
    }
    
    
    // MARK: - Standard API request functions
    
    public func getRouteTypes(failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routeTypes: [RouteType]) -> ()) {
        self.call(apiName: "route_types", searchString: "", params: nil, decodeTo: RouteTypesResponse.self, failure: failure) { (routeTypesResponse) in
            self.cache(routeTypes: routeTypesResponse.route_types)
            
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
            self.cache(routes: routesResponse.routes)
            completion(routesResponse.routes)
        }
    }
    
    public func getRoutes(forRouteTypeID routeTypeID: Int, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        self.getRoutes(failure: failure) { (routes) in
            completion(routes.filter({ $0.route_type == routeTypeID }))
        }
    }
    
    public func getRoutes(routeTypeIDs: [Int], failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
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
            let stopGeaosearches = stopsGeosearchResponse.stops
            
            self.cache(stopGeosearches: stopGeaosearches)
            completion(stopGeaosearches)
        }
    }
    
    public func getStops(onRoute routeId: Int, forRouteType routeTypeId: Int = SwiftPTVCached.TRAIN_ROUTE_TYPE, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (([StopOnRoute]) -> ())) {
        let searchString = "route/\(routeId)/route_type/\(routeTypeId)"
        
        self.call(apiName: "stops", searchString: searchString, params: nil, decodeTo: StopsOnRouteResponse.self, failure: failure) { (stopsOnRouteResponse) in
            self.cache(stopsOnRoute: stopsOnRouteResponse.stops)
            
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
            self.cache(departuresResponse: departuresResponse)
            completion(departuresResponse.departures)
        }
    }
    
    public func getStoppingPattern(forRun runId: Int, withRouteType routeTypeId: Int, failure: @escaping SwiftPTV.FailureHandler, completion: @escaping (StoppingPattern) -> ()) {
        let searchString = "run/\(String(runId))/route_type/\(routeTypeId)"
        
        self.call(apiName: "pattern", searchString: searchString, params: nil, decodeTo: StoppingPattern.self, failure: failure, completion: completion)
    }
    
    // MARK: - Populate Cache
    
    private func cache(departuresResponse: DeparturesResponse) {
        if let unwrappedDirections = departuresResponse.directions {
            self.cache(directions: unwrappedDirections.map({ $1 }))
        }
        
        if let unwrappedRuns = departuresResponse.runs {
            self.cache(runs: unwrappedRuns.map({ $1 }))
        }
        
        if let unwrappedRoutes = departuresResponse.routes {
            self.cache(routes: unwrappedRoutes.map({ $1 }))
        }
        
        if let unwrappedStops = departuresResponse.stops {
            self.cache(stopGeosearches: unwrappedStops.map({ $1 }))
        }
    }
    
    private func cache(routeTypes: [RouteType]) {
        for routeType in routeTypes {
            self.cachedRouteTypes[routeType.route_type] = routeType
        }
    }
    
    private func cache(routes: [Route]) {
        for route in routes {
            self.cachedRoutes[route.route_id] = route
        }
    }
    
    private func cache(directions: [Direction]) {
        for direction in directions {
            self.cachedDirections[direction.direction_id] = direction
        }
    }
    
    private func cache(runs: [Run]) {
        for run in runs {
            self.cachedRuns[run.run_id] = run
        }
    }
    
    private func cache(stopGeosearches: [StopGeosearch]) {
        for stopGeosearch in stopGeosearches {
            self.cachedStopsGeosearch[stopGeosearch.stop_id] = stopGeosearch
        }
    }
    private func cache(stopsOnRoute: [StopOnRoute]) {
        for stopOnRoute in stopsOnRoute {
            self.cachedStopsOnRoute[stopOnRoute.stop_id] = stopOnRoute
        }
    }
    
    public func resetCache() {
        self.cachedRouteTypes = []
        self.cachedRoutes = [:]
        self.cachedStopsGeosearch = [:]
        self.cachedRoutes = [:]
        self.cachedRuns = [:]
        self.cachedDirections = [:]
        self.cachedStopsOnRoute = [:]
    }
    
    // MARK: - Retrieve from cache
    
    // TODO: just make cache dictionaries public?
    func getRouteTypesFromCache(forRouteTypeId routeTypeId: Int) -> RouteType? {
        return cachedRouteTypes[routeTypeId]
    }
    
    // Note .distance should be ignored as this is relative to the geosearch
    func getStopGeosearchFromCache(forStopId stopId: Int) -> StopGeosearch? {
        return cachedStopsGeosearch[stopId]
    }
    
    func getRouteFromCache(forRouteId routeId: Int) -> Route? {
        return cachedRoutes[routeId]
    }
    
    func getDirectionFromCache(forDirectionId directionId: Int) -> Direction? {
        return cachedDirections[directionId]
    }
    
    func getStopOnRouteFromCache(forStopId stopId: Int) -> StopOnRoute? {
        return cachedStopsOnRoute[stopId]
    }
    
    func getCachedRun(forRunID runId: Int) -> Run? {
        return cachedRuns[runId]
    }
}
