import SwiftUI

struct PlantListView: View {
    let useDummyData: Bool

    @State private var plants: [Plant] = []
    @State private var showingAddPlant = false

    var body: some View {
        NavigationStack {
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
            .navigationTitle("My Plants")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPlant = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityIdentifier("addPlantButton")
                }
            }
            .overlay {
                if plants.isEmpty {
                    ContentUnavailableView {
                        Label("No Plants Yet", systemImage: "leaf")
                    } description: {
                        Text("Add your first plant to get started.")
                    } actions: {
                        Button("Add a Plant") {
                            showingAddPlant = true
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.green)
                    }
                }
            }
            .sheet(isPresented: $showingAddPlant) {
                AddPlantFlowView { newPlant in
                    plants.append(newPlant)
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

#Preview("Empty State") {
    PlantListView(useDummyData: false)
}
#endif
