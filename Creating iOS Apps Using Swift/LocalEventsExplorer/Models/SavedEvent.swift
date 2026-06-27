import Foundation
import SwiftData

@Model
class SavedEvent {
    var eventID: String
    var eventName: String
    var venue: String
    var city: String
    var latitude: Double
    var longitude: Double
    var eventDate: Date
    var priceMin: Double
    var priceMax: Double
    var category: String
    var dateSaved: Date

    init(
        eventID: String,
        eventName: String,
        venue: String,
        city: String,
        latitude: Double,
        longitude: Double,
        eventDate: Date,
        priceMin: Double,
        priceMax: Double,
        category: String,
        dateSaved: Date = Date()
    ) {
        self.eventID = eventID
        self.eventName = eventName
        self.venue = venue
        self.city = city
        self.latitude = latitude
        self.longitude = longitude
        self.eventDate = eventDate
        self.priceMin = priceMin
        self.priceMax = priceMax
        self.category = category
        self.dateSaved = dateSaved
    }
}
