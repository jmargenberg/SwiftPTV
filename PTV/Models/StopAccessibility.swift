import Foundation

public struct StopAccessibility: Codable {
    public let lift: Bool?
    public let wheelchair: StopAccessibilityWheelchair?
}
