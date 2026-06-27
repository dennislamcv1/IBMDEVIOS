import Foundation
import Observation

@Observable
class EventsViewModel {
    var events: [Event] = []
    var citySearchText: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil

    private let service = EventsService()

    var filteredEvents: [Event] {
        if citySearchText.isEmpty {
            return events
        }
        return events.filter {
            $0.city.localizedCaseInsensitiveContains(citySearchText)
        }
    }

    func loadEvents() async {
        isLoading = true
        errorMessage = nil
        do {
            let fetched = try await service.fetchEvents()
            events = fetched
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
