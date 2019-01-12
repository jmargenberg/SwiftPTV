import Foundation

public struct StopAccessibility: Codable {
    public let lifts: Bool
    public let wheelchair: StopAccessibilityWheelchair
}
