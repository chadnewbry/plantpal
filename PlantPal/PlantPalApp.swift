import SwiftUI

@main
struct PlantPalApp: App {
    let persistenceController: PersistenceController
    @State private var useDummyData = CommandLine.arguments.contains("-dummy-data")

    init() {
        if CommandLine.arguments.contains("-dummy-data") {
            persistenceController = .preview
        } else {
            persistenceController = .shared
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(useDummyData: useDummyData)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
