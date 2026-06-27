import SwiftUI
import Charts
import FoundationModels

struct SavedEventDetailView: View {
    let event: SavedEvent

    @State private var selectedDay: String? = nil
    @State private var tip: EventTip? = nil
    @State private var isGeneratingTips = false
    @State private var tipError: String? = nil

    private struct PricePoint: Identifiable {
        let id = UUID()
        let day: String
        let price: Double
    }

    private var priceData: [PricePoint] {
        [
            PricePoint(day: "Min", price: event.priceMin),
            PricePoint(day: "Mid", price: (event.priceMin + event.priceMax) / 2),
            PricePoint(day: "Max", price: event.priceMax)
        ]
    }

    private var priceText: String {
        if event.priceMin == 0 && event.priceMax == 0 {
            return "Free"
        }
        return "$\(Int(event.priceMin)) – $\(Int(event.priceMax))"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                // MARK: Event Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(event.category.uppercased())
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Text(event.venue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(event.city)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(
                        event.eventDate,
                        format: .dateTime.weekday(.wide).month(.wide).day().year()
                    )
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )

                // MARK: Price Chart
                VStack(alignment: .leading, spacing: 8) {
                    Text("Ticket Price Range")
                        .font(.headline)
                    Text(priceText)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Chart(priceData) { item in
                        AreaMark(
                            x: .value("Price Point", item.day),
                            y: .value("Price", item.price)
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue.opacity(0.4), .blue.opacity(0.1)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)

                        LineMark(
                            x: .value("Price Point", item.day),
                            y: .value("Price", item.price)
                        )
                        .foregroundStyle(.blue)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom)

                        if let selected = selectedDay, selected == item.day {
                            RuleMark(x: .value("Selected", item.day))
                                .foregroundStyle(.gray.opacity(0.5))
                                .annotation(position: .top) {
                                    Text("$\(Int(item.price))")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .padding(4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 4)
                                                .fill(.regularMaterial)
                                        )
                                }
                        }
                    }
                    .chartXSelection(value: $selectedDay)
                    .frame(height: 180)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )

                // MARK: AI Tips
                VStack(alignment: .leading, spacing: 12) {
                    Text("Event Tips")
                        .font(.headline)

                    if isGeneratingTips {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Generating tips…")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding()
                    } else if let tip = tip {
                        tipRow(
                            icon: "tshirt",
                            title: "What to Wear",
                            content: tip.outfitSuggestion
                        )
                        Divider()
                        tipRow(
                            icon: "bag",
                            title: "What to Bring",
                            content: tip.itemToBring
                        )
                        Divider()
                        tipRow(
                            icon: "clock",
                            title: "Arrival Tip",
                            content: tip.arrivalTip
                        )
                    } else if let error = tipError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text("Tap below to generate personalised tips for this event.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Button("Generate Tips") {
                        Task { await generateTips() }
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(isGeneratingTips)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            .padding()
        }
        .navigationTitle(event.eventName)
        .navigationBarTitleDisplayMode(.large)
    }

    @ViewBuilder
    private func tipRow(icon: String, title: String, content: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: icon)
                .font(.subheadline)
                .foregroundStyle(.blue)
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(content)
                    .font(.subheadline)
            }
        }
    }

    private func generateTips() async {
        isGeneratingTips = true
        tipError = nil
        tip = nil

        let model = SystemLanguageModel.default

        guard model.isAvailable else {
            tip = EventTip(
                outfitSuggestion: "Dress comfortably for the event. Layers are always a good idea.",
                itemToBring: "Bring a portable phone charger to stay connected.",
                arrivalTip: "Arrive 30 minutes early to find your seat and avoid the rush."
            )
            isGeneratingTips = false
            return
        }

        do {
            let session = LanguageModelSession()
            let prompt = """
            Generate event tips for: \(event.eventName)
            Venue: \(event.venue), \(event.city)
            Category: \(event.category)
            Ticket price range: \(priceText)
            """
            let result = try await session.respond(
                to: prompt,
                generating: EventTip.self
            )
            tip = result.content
        } catch {
            tipError = "Could not generate tips. Please try again."
        }

        isGeneratingTips = false
    }
}
