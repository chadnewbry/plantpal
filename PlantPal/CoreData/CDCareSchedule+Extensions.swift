import CoreData

extension CDCareSchedule {
    var wrappedCareType: CareType {
        CareType(rawValue: careType ?? "water") ?? .water
    }

    var wrappedNextDueDate: Date {
        nextDueDate ?? .now
    }

    var isOverdue: Bool {
        guard isEnabled else { return false }
        return wrappedNextDueDate <= Date()
    }
}
