# SwiftPTV

[![Build Status](https://travis-ci.org/jmargenberg/SwiftPTV.svg?branch=master)](https://travis-ci.org/jmargenberg/SwiftPTV)

API adaptor for the [PTV Timetable API v3](https://timetableapi.ptv.vic.gov.au/swagger/ui/index) written in Swift for iOS

# Classes

## PTV

Allows you to directly call the PTV API based on the api name, search string and parameters as defined in the [PTV API documentation](https://timetableapi.ptv.vic.gov.au/swagger/ui/index).

Handles the [(kind of unusual) request signing](https://static.ptv.vic.gov.au/PTV/PTV%20docs/API/1475462320/PTV-Timetable-API-key-and-signature-document.RTF) required to authenticate to the PTV API.

If successful, calls a `completion` closure with the response deocded to a `Codable` type, otherwise calls a `failure` closure with a `CallFailReason` e.g. `.AccessDenied` or `.NoNetworkConnection`.

## PTVModelled

Provides functions for specific api calls with successfull calling a `completion` closure with predefined `Codable` structs.

I've only implemented the subset of the PTV API calls that I needed to complete my project. If you need to use any other calls you should be able to follow how the existing calls are implemented to implement new functions for these calls. If you do so, please feel free to create a PR and I'll merge it in.

## PTV Cached

Similar to `SwiftPTVModelled` but any 'static' data that is returned is cached for easy retrieval later.

For example an already encountered route can be retrieved without calling the actual PTV API with `getRouteFromCache(forRouteId: 9);`.

This is especially useful when using `getDeparture(forStop, withRouteType, failure, completion)` as any directions, runs, routes and stopeed referenced in the departures are also returned and cached
