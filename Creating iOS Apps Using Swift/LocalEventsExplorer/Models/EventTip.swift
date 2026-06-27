import Foundation
import FoundationModels

@Generable
struct EventTip {
    @Guide(description: "Suggest what to wear to this event. Keep it short, one or two sentences.")
    var outfitSuggestion: String

    @Guide(description: "Suggest one useful item to bring to this event. Keep it short, one sentence.")
    var itemToBring: String

    @Guide(description: "Give a tip on when to arrive at this event. Keep it short, one sentence.")
    var arrivalTip: String
}
