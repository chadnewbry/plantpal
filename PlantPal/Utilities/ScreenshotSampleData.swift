#if DEBUG
import Foundation

enum ScreenshotSampleData {
    static var isScreenshotMode: Bool {
        ProcessInfo.processInfo.arguments.contains("--screenshot-mode")
    }

    static var samplePlants: [Plant] {
        let now = Date.now
        let cal = Calendar.current

        return [
            Plant(
                id: UUID(),
                name: "Monstera",
                species: "Monstera deliciosa",
                wateringInterval: 7,
                lastWatered: cal.date(byAdding: .day, value: -3, to: now)!,
                lightNeeds: "Bright indirect light",
                notes: "Loves humidity. Wipe leaves monthly for best growth.",
                dateAdded: cal.date(byAdding: .month, value: -8, to: now)!
            ),
            Plant(
                id: UUID(),
                name: "Snake Plant",
                species: "Dracaena trifasciata",
                wateringInterval: 14,
                lastWatered: cal.date(byAdding: .day, value: -10, to: now)!,
                lightNeeds: "Low to bright indirect",
                notes: "Very low maintenance. Perfect for beginners.",
                dateAdded: cal.date(byAdding: .month, value: -12, to: now)!
            ),
            Plant(
                id: UUID(),
                name: "Fiddle Leaf Fig",
                species: "Ficus lyrata",
                wateringInterval: 10,
                lastWatered: cal.date(byAdding: .day, value: -7, to: now)!,
                lightNeeds: "Bright indirect light",
                notes: "Sensitive to drafts. Rotate weekly for even growth.",
                dateAdded: cal.date(byAdding: .month, value: -5, to: now)!
            ),
            Plant(
                id: UUID(),
                name: "Pothos",
                species: "Epipremnum aureum",
                wateringInterval: 7,
                lastWatered: cal.date(byAdding: .day, value: -5, to: now)!,
                lightNeeds: "Low to bright indirect",
                notes: "Trail or climb. Propagates easily in water.",
                dateAdded: cal.date(byAdding: .month, value: -10, to: now)!
            ),
            Plant(
                id: UUID(),
                name: "Peace Lily",
                species: "Spathiphyllum wallisii",
                wateringInterval: 5,
                lastWatered: cal.date(byAdding: .day, value: -2, to: now)!,
                lightNeeds: "Low to medium indirect",
                notes: "Droops when thirsty. Mist leaves regularly.",
                dateAdded: cal.date(byAdding: .month, value: -4, to: now)!
            ),
            Plant(
                id: UUID(),
                name: "Bird of Paradise",
                species: "Strelitzia reginae",
                wateringInterval: 10,
                lastWatered: cal.date(byAdding: .day, value: -6, to: now)!,
                lightNeeds: "Bright direct to indirect",
                notes: "Dramatic foliage. Needs space to spread.",
                dateAdded: cal.date(byAdding: .month, value: -3, to: now)!
            ),
        ]
    }
}
#endif
