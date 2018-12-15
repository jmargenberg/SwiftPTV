import Foundation

struct StoppingPattern: Codable {
    let departures: [Departure]
    let disruptions: [Disruption]
    
    // TODO: extract to extension
    func departuresUntilDestination(after time: Date, withCachedAPI ptv: SwiftPTVCached) -> ArraySlice<Departure>? {
        let sortedDepartures = departures.sorted(by: { $0.bestAvailableDepartureTimeUTCString < $1.bestAvailableDepartureTimeUTCString })
        
        let nextDepartureIndex = sortedDepartures.index(where: { $0.bestAvailableDepartureTime > time })
        if nextDepartureIndex != nil {
            let nextDeparture = sortedDepartures[nextDepartureIndex!]
            
            let futureDepartures = sortedDepartures[nextDepartureIndex!...]
            
            let destinationName = ptv.getDirectionFromCache(forDirectionId: nextDeparture.direction_id)!.direction_name
            
            let destinationIndex = futureDepartures.index { (departure) -> Bool in
                let stopName = ptv.getStopOnRouteFromCache(forStopId: departure.stop_id)!.stop_name
                
                return destinationName.range(of: stopName) != nil //i.e stop name is contained in destination name
            }
            
            if destinationIndex != nil {
                return futureDepartures[...destinationIndex!]
            } else {
                return futureDepartures
            }
        } else {
            return nil
        }
        
    }
}
