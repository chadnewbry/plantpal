import Foundation

struct Plant: Identifiable {
    let id: UUID
    var name: String
    var species: String
    var wateringInterval: Int // days
    var lastWatered: Date
    var lightNeeds: String
    var notes: String
    var dateAdded: Date
}

#if DEBUG
extension Plant: PreviewData {
    static var preview: Plant {
        Plant(
            id: UUID(),
            name: "Monstera",
            species: "Monstera deliciosa",
            wateringInterval: 7,
            lastWatered: Calendar.current.date(byAdding: .day, value: -3, to: .now)!,
            lightNeeds: "Bright indirect light",
            notes: "Loves humidity. Wipe leaves monthly.",
            dateAdded: Calendar.current.date(byAdding: .month, value: -6, to: .now)!
        )
    }

    static var previewList: [Plant] {
        [
            preview,
            Plant(
                id: UUID(),
                name: "Snake Plant",
                species: "Dracaena trifasciata",
                wateringInterval: 14,
                lastWatered: Calendar.current.date(byAdding: .day, value: -10, to: .now)!,
                lightNeeds: "Low to bright indirect light",
                notes: "Very low maintenance. Tolerates neglect well.",
                dateAdded: Calendar.current.date(byAdding: .month, value: -12, to: .now)!
            ),
            Plant(
                id: UUID(),
                name: "Pothos",
                species: "Epipremnum aureum",
                wateringInterval: 7,
                lastWatered: Calendar.current.date(byAdding: .day, value: -5, to: .now)!,
                lightNeeds: "Low to bright indirect light",
                notes: "Trail or climb. Propagates easily in water.",
                dateAdded: Calendar.current.date(byAdding: .month, value: -8, to: .now)!
            ),
            Plant(
                id: UUID(),
                name: "Fiddle Leaf Fig",
                species: "Ficus lyrata",
                wateringInterval: 10,
                lastWatered: Calendar.current.date(byAdding: .day, value: -7, to: .now)!,
                lightNeeds: "Bright indirect light",
                notes: "Sensitive to drafts and temperature changes. Rotate weekly.",
                dateAdded: Calendar.current.date(byAdding: .month, value: -3, to: .now)!
            ),
            Plant(
                id: UUID(),
                name: "Peace Lily",
                species: "Spathiphyllum wallisii",
                wateringInterval: 5,
                lastWatered: Calendar.current.date(byAdding: .day, value: -2, to: .now)!,
                lightNeeds: "Low to medium indirect light",
                notes: "Droops when thirsty. Mist leaves regularly.",
                dateAdded: Calendar.current.date(byAdding: .month, value: -4, to: .now)!
            ),
        ]
    }
}
#endif
