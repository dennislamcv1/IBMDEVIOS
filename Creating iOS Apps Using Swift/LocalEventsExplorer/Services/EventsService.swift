import Foundation

final class EventsService {
    private let url = URL(
        string: "https://cf-courses-data.s3.us.cloud-object-storage.appdomain.cloud/F3Y3rrlatukAJ_mAJT4a8Q/events.json"
    )!

    func fetchEvents() async throws -> [Event] {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let eventsResponse = try decoder.decode(EventsResponse.self, from: data)
        return eventsResponse.events
    }
}
