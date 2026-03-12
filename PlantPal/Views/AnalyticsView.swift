import SwiftUI

struct AnalyticsView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "chart.bar.fill",
                description: Text("Plant health trends and watering analytics will appear here.")
            )
            .navigationTitle("Analytics")
        }
    }
}

#if DEBUG
#Preview {
    AnalyticsView()
}
#endif
