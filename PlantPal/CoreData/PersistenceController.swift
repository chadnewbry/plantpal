import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext

        // Create sample plants
        for plantData in Plant.previewList {
            let cdPlant = CDPlant(context: context)
            cdPlant.id = plantData.id
            cdPlant.name = plantData.name
            cdPlant.species = plantData.species
            cdPlant.wateringInterval = Int16(plantData.wateringInterval)
            cdPlant.lastWatered = plantData.lastWatered
            cdPlant.lightNeeds = plantData.lightNeeds
            cdPlant.notes = plantData.notes
            cdPlant.dateAdded = plantData.dateAdded

            // Add a default watering schedule
            let schedule = CDCareSchedule(context: context)
            schedule.id = UUID()
            schedule.careType = CareType.water.rawValue
            schedule.intervalDays = Int16(plantData.wateringInterval)
            schedule.isEnabled = true
            schedule.nextDueDate = Calendar.current.date(byAdding: .day, value: plantData.wateringInterval, to: plantData.lastWatered)
            schedule.plant = cdPlant

            // Add a sample care event
            let event = CDCareEvent(context: context)
            event.id = UUID()
            event.careType = CareType.water.rawValue
            event.date = plantData.lastWatered
            event.plant = cdPlant
        }

        do {
            try context.save()
        } catch {
            fatalError("Preview PersistenceController save error: \(error)")
        }

        return controller
    }()

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "PlantPal")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Core Data store failed to load: \(error), \(error.userInfo)")
            }
        }

        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Core Data save error: \(nsError), \(nsError.userInfo)")
        }
    }
}
