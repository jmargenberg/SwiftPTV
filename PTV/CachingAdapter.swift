import UIKit
import CoreLocation

/**
 Adapts most methods of the PTV RESTful API, decoding all json responses and returning codable structs, whilst caching (most) encountered objects for cheap retrieval at a later time.
 
 Essentially all objects returned that are likely to be 'static' (not change between calls) are stored in a cache accessed by a method get[ObjectName]FromCache(where[ObjectName]Id[id])

 Cached Objects:
 - RouteType
 - StopGeosearch (although .distance should be ignore if retrieved from cache)
 - Run
 - Direction
 - StopsOnRoute
 Non-cached Objects:
 - Departure
 
 Non-cached requests pass results to completion closures, Cached requests use standard return types.
 
  ## PTV Stops
 The PTV API provides 3 different types of Stops, each holding slightly different information:
 - StopGeosearch - getStops(nearLocation:  forRouteTypes: maxResults: maxDistance: completion: ) - all stops near a given location
 - StopOnRoute - getStops(onRoute: forRouteType: completion: ) - all the stops for a given route
 - StopDetails - getStopDetails(forStop: forRouteType: completion: ) - detailed description of stop including amenities
 */
public class CachingAdapter: ModelledAdapter {
    
    private var cachedRouteTypes: [RouteType]
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
    
    public override func getRouteTypes(failure: @escaping Adapter.FailureHandler, completion: @escaping (_ routeTypes: [RouteType]) -> ()) {
        super.getRouteTypes(failure: failure) { (routeTypes) in
            self.cache(routeTypes: routeTypes)
            completion(routeTypes)
        }
    }
    
    public override func getRoutes(failure: @escaping Adapter.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        super.getRoutes(failure: failure) { (routes) in
            self.cache(routes: routes)
            completion(routes)
        }
    }
    
    public override func getRoutes(forRouteTypeID routeTypeID: Int, failure: @escaping Adapter.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        super.getRoutes(forRouteTypeID: routeTypeID, failure: failure) { (routes) in
            self.cache(routes: routes)
            completion(routes)
        }
    }
    
    public override func getRoutes(forRouteTypeIDs routeTypeIDs: [Int], failure: @escaping Adapter.FailureHandler, completion: @escaping (_ routes: [Route]) -> ()) {
        super.getRoutes(forRouteTypeIDs: routeTypeIDs, failure: failure) { (routes) in
            self.cache(routes: routes)
            completion(routes)
        }
    }
    
    public override func getStops(nearLocation location: CLLocationCoordinate2D, forRouteTypes routeTypes: [Int] = [CachingAdapter.TRAIN_ROUTE_TYPE], maxResults: Int = 1000, maxDistance: Int = 5000, failure: @escaping Adapter.FailureHandler, completion: @escaping (([StopGeosearch]) -> ())) {
        super.getStops(nearLocation: location, forRouteTypes: routeTypes, failure: failure) { (stopGeaosearches) in
            self.cache(stopGeosearches: stopGeaosearches)
            completion(stopGeaosearches)
        }
    }
    
    public override func getStops(onRoute routeId: Int, forRouteType routeTypeId: Int = CachingAdapter.TRAIN_ROUTE_TYPE, failure: @escaping Adapter.FailureHandler, completion: @escaping (([StopOnRoute]) -> ())) {
        super.getStops(onRoute: routeId, forRouteType: routeTypeId, failure: failure) { (stopsOnRoute) in
            self.cache(stopsOnRoute: stopsOnRoute)
            
            completion(stopsOnRoute)
        }
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
