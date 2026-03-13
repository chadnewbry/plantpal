import SwiftUI
import RevenueCat

@main
struct PlantPalApp: App {
    @State private var useDummyData = CommandLine.arguments.contains("-dummy-data")

    init() {
        PlantPalProManager.shared.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView(useDummyData: useDummyData)
                .environmentObject(PlantPalProManager.shared)
        }
    }
}
