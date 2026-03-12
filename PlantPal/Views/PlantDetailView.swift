import SwiftUI

struct PlantDetailView: View {
    let plant: Plant

    var body: some View {
        List {
            Section("Details") {
                LabeledContent("Species", value: plant.species)
                LabeledContent("Light Needs", value: plant.lightNeeds)
                LabeledContent("Watering Interval", value: "\(plant.wateringInterval) days")
            }

            Section("Watering") {
                LabeledContent("Last Watered", value: plant.lastWatered, format: .dateTime.month().day().year())
                LabeledContent("Days Since Watered", value: "\(daysSinceWatered)")
            }

            if !plant.notes.isEmpty {
                Section("Notes") {
                    Text(plant.notes)
                }
            }

            Section("Info") {
                LabeledContent("Date Added", value: plant.dateAdded, format: .dateTime.month().day().year())
            }
        }
        .navigationTitle(plant.name)
    }

    private var daysSinceWatered: Int {
        Calendar.current.dateComponents([.day], from: plant.lastWatered, to: .now).day ?? 0
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PlantDetailView(plant: .preview)
    }
}
#endif
