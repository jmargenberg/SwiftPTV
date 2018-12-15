import Foundation

struct Direction: Codable {
    let direction_id: Int
    let direction_name: String
    let route_id: Int?
    let route_type: Int?
    
    // TODO: extract to extensions
    var shortened_direction_name: String {
        get {
            switch direction_name {
            case "City (Flinders Street)":
                return "Flinders Street"
            case "South Morang/Mernda":
                return "South Morang"
            case "Showgrounds / Flemington Racecourse":
                return "Showgrounds"
            default:
                return direction_name
            }
        }
    }
}
