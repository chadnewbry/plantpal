import CoreData

extension CDCareEvent {
    var wrappedCareType: CareType {
        CareType(rawValue: careType ?? "water") ?? .water
    }

    var wrappedDate: Date {
        date ?? .now
    }

    var wrappedNotes: String {
        notes ?? ""
    }
}
