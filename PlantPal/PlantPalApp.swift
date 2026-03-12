import SwiftUI

@main
struct PlantPalApp: App {
    @State private var useDummyData = CommandLine.arguments.contains("-dummy-data")

    var body: some Scene {
        WindowGroup {
            ContentView(useDummyData: useDummyData)
        }
    }
}
