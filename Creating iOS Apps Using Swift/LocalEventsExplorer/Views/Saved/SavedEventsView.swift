import SwiftUI
import SwiftData

struct SavedEventsView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \SavedEvent.dateSaved, order: .reverse) private var savedEvents: [SavedEvent]
    @State private var searchText = ""

    private var filteredEvents: [SavedEvent] {
        if searchText.isEmpty {
            return savedEvents
        }
        return savedEvents.filter {
            $0.eventName.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filteredEvents) { event in
                    NavigationLink(destination: SavedEventDetailView(event: event)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(event.eventName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text(event.city)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(
                                event.eventDate,
                                format: .dateTime.month(.abbreviated).day().year()
                            )
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        context.delete(filteredEvents[index])
                    }
                }
            }
            .navigationTitle("Saved")
            .searchable(text: $searchText, prompt: "Search saved events")
            .overlay {
                if savedEvents.isEmpty {
                    ContentUnavailableView(
                        "No Saved Events",
                        systemImage: "heart",
                        description: Text("Save events from the Events tab to see them here.")
                    )
                }
            }
        }
    }
}
