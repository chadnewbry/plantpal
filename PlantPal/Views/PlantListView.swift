import SwiftUI

struct PlantListView: View {
    let useDummyData: Bool

    @State private var plants: [Plant] = []
    @AppStorage("plantViewStyle") private var showGrid: Bool = false

    var body: some View {
        NavigationStack {
            Group {
                if showGrid {
                    PlantGridView(plants: plants)
                } else {
                    List(plants) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant)) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(plant.name)
                                        .font(.headline)
                                    Text(plant.species)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                if daysSinceWatered(plant) >= plant.wateringInterval {
                                    Image(systemName: "drop.fill")
                                        .foregroundStyle(.blue)
                                        .accessibilityLabel("Needs watering")
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }
            }
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showGrid.toggle()
                        }
                    } label: {
                        Image(systemName: showGrid ? "list.bullet" : "square.grid.2x2")
                    }
                    .accessibilityLabel(showGrid ? "Switch to list" : "Switch to grid")
                    .accessibilityIdentifier("viewStyleToggle")
                }
            }
            .overlay {
                if plants.isEmpty && !showGrid {
                    ContentUnavailableView(
                        "No Plants Yet",
                        systemImage: "leaf",
                        description: Text("Add your first plant to get started.")
                    )
                }
            }
            .onAppear {
                if useDummyData && plants.isEmpty {
                    #if DEBUG
                    plants = Plant.previewList
                    #endif
                }
            }
        }
    }

    private func daysSinceWatered(_ plant: Plant) -> Int {
        Calendar.current.dateComponents([.day], from: plant.lastWatered, to: .now).day ?? 0
    }
}

#if DEBUG
#Preview {
    PlantListView(useDummyData: true)
}
#endif
