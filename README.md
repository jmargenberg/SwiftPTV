# PTV

[![Build Status](https://travis-ci.org/jmargenberg/SwiftPTV.svg?branch=master)](https://travis-ci.org/jmargenberg/SwiftPTV) [![](https://img.shields.io/cocoapods/v/PTV.svg)](https://cocoapods.org/pods/PTV)

API adaptor for the [PTV Timetable API v3](https://timetableapi.ptv.vic.gov.au/swagger/ui/index) written in Swift for iOS.

## Installation
This library can be installed using [cocoapods](https://cocoapods.org/pods/PTV).

Just add `pod 'PTV', '~> 0.2'` to your podfile and run `pod install`.

## Adapter Classes

### Modelled Adapter
```
import PTV

let ptv = PTV.ModelledAdapter(devid: "1234567", key: "12345678901234567890")
```

Provides functions for specific api calls with successfull calls calling a `completion` closure with predefined `Codable` structs and failing calls calling a `failure` closure with `CallFailReason`  enum (e.g.  `.AccessDenied` or `.NoNetworkConnection`) and `message` string

I've only implemented the subset of the PTV API calls that I needed to complete my project. If you need to use any other calls you should be able to follow how the existing calls are implemented to implement new functions for these calls. If you do so, please feel free to create a PR and I'll merge it in.

#### Implemented Functions
##### Routes
*  `getRouteTypes(failure: Adapter.FailureHandler) { routeTypes: [RouteType]) in _ }`
*  `getRoutes(failure: Adapter.FailureHandler) { routes: [Route] in _ }`
*  `getRoutes(forRouteTypeID: Int, failure: Adapter.FailureHandler) { routes: [Route]) in _ }`
*  `getRoutes(forRouteTypeIDs: [Int], failure: Adapter.FailureHandler) { routes: [Route]) in _ }`

##### Stops

*  `getStops(nearLocation: CLLocationCoordinate2D, forRouteTypes: [Int], maxResults: Int, maxDistance: Int, failure: Adapter.FailureHandler) { stops: [StopGeosearch]) in _ }`
*  `getStops(onRoute: Int, forRouteType: Int, failure: Adapter.FailureHandler) { stops: [StopOnRoute]) in _ }`
*  `getStopDetails(forStop: Int, forRouteType: Int, failure: Adapter.FailureHandler) {stop: StopDetails in _ }`

##### Departures and Stopping Patterns
*  `getDepartures(forStop: Int, withRouteType: Int, failure: Adapter.FailureHandler) { departures: [Departure] in _ }`
*  `getStoppingPattern(forRun: Int, withRouteType: Int, failure: Adapter.FailureHandler) {stoppingPattern: StoppingPattern) in _ }`

Note that `Adapter.FailureHandler` is a typealias for the function type `(_ callFailReason: CallFailReason, _ message: String?) -> ()`

###  Caching Adapter
```
import PTV

let ptv = PTV.CachingAdapter(devid: "1234567", key: "12345678901234567890")
```

Subclas of  `PTV.ModelledAdapter` where any 'static' data that is returned is cached for easy retrieval later.

For example an already encountered route can be retrieved with `getRouteFromCache(forRouteId: 9);` without having to make an actual api call.

This is especially useful when using `getDeparture(forStop, withRouteType, failure, completion)` as any directions, runs, routes or stops referenced in the returned departures are cached for cheap retrieval later.

### Plain Adapter
```
import PTV

let ptv = PTV.Adapter(devid: "1234567", key: "12345678901234567890")
```

Allows you to directly call the PTV API based on the api name, search string and parameters as defined in the [PTV API documentation](https://timetableapi.ptv.vic.gov.au/swagger/ui/index).

You should only need to use this if you need an api call not covered by `ModelledAdapter` or `CachingAdapter`.

Handles the [(kind of unusual) request signing](https://static.ptv.vic.gov.au/PTV/PTV%20docs/API/1475462320/PTV-Timetable-API-key-and-signature-document.RTF) required to authenticate to the PTV API.

If successful, calls a `completion` closure with the response deocded to a `Codable` type, otherwise calls a `failure` closure with a `CallFailReason` e.g. `.AccessDenied` or `.NoNetworkConnection`.

