import Foundation

struct Event: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let city: String
    let venueName: String
    let eventDate: Date
    let latitude: Double
    let longitude: Double
    let priceMin: Double
    let priceMax: Double

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case category
        case city
        case venueName = "venue_name"
        case eventDate = "event_date"
        case latitude
        case longitude
        case priceMin = "price_min"
        case priceMax = "price_max"
    }
}
