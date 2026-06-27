import SwiftUI

struct EventCard: View {
    let event: Event
    let isSaved: Bool
    let onSaveTapped: () -> Void

    @ScaledMetric(relativeTo: .body) private var cardSpacing: CGFloat = 12
    @ScaledMetric(relativeTo: .body) private var iconSize: CGFloat = 14

    private var priceText: String {
        if event.priceMin == 0 && event.priceMax == 0 {
            return "Free"
        } else if event.priceMin == 0 {
            return "Up to $\(Int(event.priceMax))"
        } else {
            return "$\(Int(event.priceMin)) – $\(Int(event.priceMax))"
        }
    }

    private var categoryIcon: String {
        switch event.category {
        case "Concert": return "music.note"
        case "Sports": return "sportscourt"
        case "Theater": return "theatermasks"
        case "Comedy": return "face.smiling"
        case "Festival": return "star"
        default: return "calendar"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: cardSpacing) {
            HStack {
                Image(systemName: categoryIcon)
                    .font(.system(size: iconSize))
                    .foregroundStyle(.secondary)
                Text(event.category)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onSaveTapped) {
                    Image(systemName: isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(isSaved ? .red : .secondary)
                        .font(.system(size: iconSize + 2))
                }
                .buttonStyle(.plain)
            }

            Text(event.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(event.venueName)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Text(
                event.eventDate,
                format: .dateTime.month(.abbreviated).day().year()
            )
            .font(.caption)
            .foregroundStyle(.secondary)

            Text(priceText)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.primary)
                .contentTransition(.numericText())
        }
        .padding(cardSpacing)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(Color(.separator), lineWidth: 0.5)
        )
    }
}
