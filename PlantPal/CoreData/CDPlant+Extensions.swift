import CoreData

extension CDPlant {
    var wrappedName: String {
        name ?? ""
    }

    var wrappedSpecies: String {
        species ?? ""
    }

    var wrappedLightNeeds: String {
        lightNeeds ?? ""
    }

    var wrappedNotes: String {
        notes ?? ""
    }

    var wrappedDateAdded: Date {
        dateAdded ?? .now
    }

    var careEventsArray: [CDCareEvent] {
        let set = careEvents as? Set<CDCareEvent> ?? []
        return set.sorted { ($0.date ?? .distantPast) > ($1.date ?? .distantPast) }
    }

    var careSchedulesArray: [CDCareSchedule] {
        let set = careSchedules as? Set<CDCareSchedule> ?? []
        return set.sorted { ($0.careType ?? "") < ($1.careType ?? "") }
    }

    var nextWateringDate: Date? {
        guard let lastWatered = lastWatered else { return nil }
        return Calendar.current.date(byAdding: .day, value: Int(wateringInterval), to: lastWatered)
    }

    var needsWatering: Bool {
        guard let nextDate = nextWateringDate else { return true }
        return nextDate <= Date()
    }

    /// Convert to the lightweight Plant struct for views/previews
    var asPlant: Plant {
        Plant(
            id: id ?? UUID(),
            name: wrappedName,
            species: wrappedSpecies,
            wateringInterval: Int(wateringInterval),
            lastWatered: lastWatered ?? .now,
            lightNeeds: wrappedLightNeeds,
            notes: wrappedNotes,
            dateAdded: wrappedDateAdded
        )
    }
}
