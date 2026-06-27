import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var savedEvents: [SavedEvent]

    @State private var viewModel = EventsViewModel()
    @State private var animateCards = false

    private let columns = [
        GridItem(.adaptive(minimum: 160))
    ]

    var body: some View {
        TabView {
            // MARK: Events Tab
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Events")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        TextField(
                            "Enter city (e.g., Dallas)",
                            text: $viewModel.citySearchText
                        )
                        .textFieldStyle(.roundedBorder)

                        Button("Find Events") {
                            Task {
                                animateCards = false
                                await viewModel.loadEvents()
                                try? await Task.sleep(for: .milliseconds(150))
                                withAnimation(.spring()) {
                                    animateCards = true
                                }
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        // Loading state
                        if viewModel.isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .transition(.opacity)
                                Spacer()
                            }
                        }

                        // Error state
                        if let errorMessage = viewModel.errorMessage {
                            VStack(spacing: 10) {
                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundStyle(.red)
                                    .multilineTextAlignment(.center)

                                Button("Retry") {
                                    Task {
                                        animateCards = false
                                        await viewModel.loadEvents()
                                        try? await Task.sleep(for: .milliseconds(150))
                                        withAnimation(.spring()) {
                                            animateCards = true
                                        }
                                    }
                                }
                                .buttonStyle(.bordered)
                            }
                            .frame(maxWidth: .infinity)
                            .transition(
                                .move(edge: .bottom)
                                .combined(with: .opacity)
                            )
                        }

                        // Events grid
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(
                                Array(viewModel.filteredEvents.enumerated()),
                                id: \.element.id
                            ) { index, event in
                                EventCard(
                                    event: event,
                                    isSaved: isSaved(event),
                                    onSaveTapped: { toggleSave(event) }
                                )
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 60)
                                .animation(
                                    .easeInOut(duration: 0.7)
                                    .delay(Double(index) * 0.08),
                                    value: animateCards
                                )
                            }
                        }
                    }
                    .padding()
                }
            }
            .tabItem {
                Label("Events", systemImage: "calendar")
            }

            // MARK: Map Tab
            EventsMapView(events: viewModel.filteredEvents)
                .tabItem {
                    Label("Map", systemImage: "map")
                }

            // MARK: Saved Tab
            SavedEventsView()
                .tabItem {
                    Label("Saved", systemImage: "heart")
                }
        }
    }

    // MARK: Save toggle helpers

    private func isSaved(_ event: Event) -> Bool {
        savedEvents.contains { $0.eventID == event.id }
    }

    private func toggleSave(_ event: Event) {
        if let existing = savedEvents.first(where: { $0.eventID == event.id }) {
            context.delete(existing)
        } else {
            let saved = SavedEvent(
                eventID: event.id,
                eventName: event.name,
                venue: event.venueName,
                city: event.city,
                latitude: event.latitude,
                longitude: event.longitude,
                eventDate: event.eventDate,
                priceMin: event.priceMin,
                priceMax: event.priceMax,
                category: event.category
            )
            context.insert(saved)
        }
    }
}
