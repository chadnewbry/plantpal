import SwiftUI

struct CalendarView: View {
    var body: some View {
        NavigationStack {
            ContentUnavailableView(
                "Coming Soon",
                systemImage: "calendar",
                description: Text("Watering schedule and reminders will appear here.")
            )
            .navigationTitle("Calendar")
        }
    }
}

#if DEBUG
#Preview {
    CalendarView()
}
#endif
