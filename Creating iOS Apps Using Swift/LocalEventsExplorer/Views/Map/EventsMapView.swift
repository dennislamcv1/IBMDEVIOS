import SwiftUI
import MapKit

struct EventsMapView: View {
    let events: [Event]

    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 31.9686, longitude: -99.9018),
            span: MKCoordinateSpan(latitudeDelta: 8.0, longitudeDelta: 8.0)
        )
    )
    @State private var selectedMapStyle = "Standard"

    private var currentMapStyle: MapStyle {
        switch selectedMapStyle {
        case "Imagery":
            return .imagery
        case "Hybrid":
            return .hybrid
        default:
            return .standard
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Map(position: $position) {
                ForEach(events) { event in
                    Annotation(
                        event.name,
                        coordinate: CLLocationCoordinate2D(
                            latitude: event.latitude,
                            longitude: event.longitude
                        )
                    ) {
                        VStack(spacing: 4) {
                            ZStack {
                                Circle()
                                    .fill(categoryColor(for: event.category))
                                    .frame(width: 36, height: 36)
                                Image(systemName: categoryIcon(for: event.category))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                            .shadow(radius: 3)

                            VStack(spacing: 2) {
                                Text(event.name)
                                    .font(.caption2)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                                Text(priceLabel(for: event))
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 6)
                            .padding(.vertical, 3)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(.regularMaterial)
                            )
                        }
                    }
                }
            }
            .mapStyle(currentMapStyle)
            .ignoresSafeArea(edges: .top)

            VStack(spacing: 0) {
                HStack {
                    Picker("Map Style", selection: $selectedMapStyle) {
                        Text("Standard").tag("Standard")
                        Text("Imagery").tag("Imagery")
                        Text("Hybrid").tag("Hybrid")
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    Button {
                        withAnimation {
                            position = .userLocation(fallback: .automatic)
                        }
                    } label: {
                        Image(systemName: "location.fill")
                            .padding(10)
                            .background(Circle().fill(.regularMaterial))
                    }
                    .padding(.trailing)
                }
                .padding(.vertical, 10)
                .background(.regularMaterial)
            }
        }
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func categoryIcon(for category: String) -> String {
        switch category {
        case "Concert": return "music.note"
        case "Sports": return "sportscourt"
        case "Theater": return "theatermasks"
        case "Comedy": return "face.smiling"
        case "Festival": return "star.fill"
        default: return "mappin"
        }
    }

    private func categoryColor(for category: String) -> Color {
        switch category {
        case "Concert": return .purple
        case "Sports": return .blue
        case "Theater": return .orange
        case "Comedy": return .yellow
        case "Festival": return .green
        default: return .red
        }
    }

    private func priceLabel(for event: Event) -> String {
        if event.priceMin == 0 && event.priceMax == 0 {
            return "Free"
        }
        return "$\(Int(event.priceMin))–$\(Int(event.priceMax))"
    }
}
