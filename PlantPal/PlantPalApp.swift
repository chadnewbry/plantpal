import SwiftUI

@main
struct PlantPalApp: App {
    @State private var useDummyData: Bool = {
        #if DEBUG
        if ScreenshotSampleData.isScreenshotMode {
            return true
        }
        #endif
        return CommandLine.arguments.contains("-dummy-data")
    }()

    var body: some Scene {
        WindowGroup {
            ContentView(useDummyData: useDummyData)
        }
    }
}
