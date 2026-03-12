import SwiftUI

struct PlantGridView: View {
    let plants: [Plant]

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            if plants.isEmpty {
                ContentUnavailableView(
                    "No Plants Yet",
                    systemImage: "leaf",
                    description: Text("Add your first plant to get started.")
                )
                .frame(maxHeight: .infinity)
            } else {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(plants) { plant in
                        NavigationLink(destination: PlantDetailView(plant: plant)) {
                            PlantGridCell(plant: plant)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding()
            }
        }
    }
}

struct PlantGridCell: View {
    let plant: Plant

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 16)
                    .fill(plantColor.opacity(0.15))
                    .frame(height: 120)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(plantColor)
            }

            VStack(spacing: 2) {
                Text(plant.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(plant.species)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack(spacing: 12) {
                Label("\(plant.wateringInterval)d", systemImage: "drop")
                    .font(.caption2)
                    .foregroundStyle(.blue)

                if needsWatering {
                    Label("Thirsty", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 8, y: 2)
        )
        .accessibilityIdentifier("plantGridCell_\(plant.name)")
    }

    private var needsWatering: Bool {
        let days = Calendar.current.dateComponents([.day], from: plant.lastWatered, to: .now).day ?? 0
        return days >= plant.wateringInterval
    }

    private var plantColor: Color {
        needsWatering ? .orange : .green
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        PlantGridView(plants: Plant.previewList)
            .navigationTitle("My Plants")
    }
}
#endif
