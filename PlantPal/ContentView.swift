import SwiftUI

struct ContentView: View {
    let useDummyData: Bool

    var body: some View {
        TabView {
            PlantListView(useDummyData: useDummyData)
                .tabItem {
                    Label("My Plants", systemImage: "leaf.fill")
                }
                .accessibilityIdentifier("myPlantsTab")

            CalendarView()
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .accessibilityIdentifier("calendarTab")

            AnalyticsView()
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .accessibilityIdentifier("analyticsTab")

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .accessibilityIdentifier("settingsTab")
        }
    }
}

#if DEBUG
#Preview {
    ContentView(useDummyData: true)
}
#endif
