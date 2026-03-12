import SwiftUI

struct AddPlantFlowView: View {
    @Environment(\.dismiss) private var dismiss
    var onComplete: (Plant) -> Void

    @State private var step: FlowStep = .name
    @State private var plantName = ""
    @State private var species = ""
    @State private var lightNeeds: LightNeeds = .brightIndirect
    @State private var wateringInterval = 7
    @State private var notes = ""

    enum FlowStep: Int, CaseIterable {
        case name, species, light, watering, review
    }

    enum LightNeeds: String, CaseIterable, Identifiable {
        case directSun = "Direct sunlight"
        case brightIndirect = "Bright indirect light"
        case mediumIndirect = "Medium indirect light"
        case lowLight = "Low light"

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .directSun: "sun.max.fill"
            case .brightIndirect: "sun.min.fill"
            case .mediumIndirect: "cloud.sun.fill"
            case .lowLight: "cloud.fill"
            }
        }
    }

    private var progress: Double {
        Double(step.rawValue) / Double(FlowStep.allCases.count - 1)
    }

    private var canAdvance: Bool {
        switch step {
        case .name: !plantName.trimmingCharacters(in: .whitespaces).isEmpty
        case .species: !species.trimmingCharacters(in: .whitespaces).isEmpty
        case .light, .watering, .review: true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: progress)
                    .tint(.green)
                    .padding(.horizontal)
                    .padding(.top, 8)

                Group {
                    switch step {
                    case .name: nameStep
                    case .species: speciesStep
                    case .light: lightStep
                    case .watering: wateringStep
                    case .review: reviewStep
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                bottomBar
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .animation(.easeInOut(duration: 0.25), value: step)
        }
        .interactiveDismissDisabled()
    }

    // MARK: - Steps

    private var nameStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "leaf.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("What's your plant's name?")
                .font(.title2.weight(.semibold))
            Text("Give it a nickname — whatever feels right.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("e.g. Monstera, Desk Fern", text: $plantName)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .submitLabel(.next)
                .onSubmit { advance() }
            Spacer()
            Spacer()
        }
        .padding()
    }

    private var speciesStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("What species is it?")
                .font(.title2.weight(.semibold))
            Text("The common or scientific name works.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("e.g. Monstera deliciosa", text: $species)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, 40)
                .submitLabel(.next)
                .onSubmit { advance() }
            Spacer()
            Spacer()
        }
        .padding()
    }

    private var lightStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Text("How much light does it need?")
                .font(.title2.weight(.semibold))
            Text("Where does your plant sit?")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 12) {
                ForEach(LightNeeds.allCases) { option in
                    Button {
                        lightNeeds = option
                    } label: {
                        HStack {
                            Image(systemName: option.icon)
                                .frame(width: 24)
                            Text(option.rawValue)
                            Spacer()
                            if lightNeeds == option {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.green)
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(lightNeeds == option ? Color.green.opacity(0.1) : Color(.systemGray6))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(lightNeeds == option ? Color.green : Color.clear, lineWidth: 2)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }

    private var wateringStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "drop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.blue)
            Text("How often should you water?")
                .font(.title2.weight(.semibold))
            Text("We'll remind you when it's time.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Every \(wateringInterval) days")
                    .font(.title3.weight(.medium))
                    .monospacedDigit()
                Stepper("Watering interval", value: $wateringInterval, in: 1...60)
                    .labelsHidden()
            }
            .padding(.horizontal, 60)

            Spacer()
            Spacer()
        }
        .padding()
    }

    private var reviewStep: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)
            Text("Looking good!")
                .font(.title2.weight(.semibold))
            Text("Here's a summary of your new plant.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 12) {
                reviewRow(icon: "leaf.fill", label: "Name", value: plantName)
                reviewRow(icon: "magnifyingglass", label: "Species", value: species)
                reviewRow(icon: lightNeeds.icon, label: "Light", value: lightNeeds.rawValue)
                reviewRow(icon: "drop.fill", label: "Watering", value: "Every \(wateringInterval) days")
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
            .padding(.horizontal, 24)

            TextField("Any notes? (optional)", text: $notes, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
                .padding(.horizontal, 24)

            Spacer()
        }
        .padding()
    }

    private func reviewRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundStyle(.secondary)
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }

    // MARK: - Navigation

    private var stepTitle: String {
        switch step {
        case .name: "Add Plant"
        case .species: "Species"
        case .light: "Light"
        case .watering: "Watering"
        case .review: "Review"
        }
    }

    private var bottomBar: some View {
        HStack {
            if step != .name {
                Button("Back") { goBack() }
                    .buttonStyle(.bordered)
            }
            Spacer()
            if step == .review {
                Button("Add Plant") { savePlant() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
            } else {
                Button("Next") { advance() }
                    .buttonStyle(.borderedProminent)
                    .tint(.green)
                    .disabled(!canAdvance)
            }
        }
        .padding()
    }

    private func advance() {
        guard canAdvance else { return }
        if let next = FlowStep(rawValue: step.rawValue + 1) {
            step = next
        }
    }

    private func goBack() {
        if let prev = FlowStep(rawValue: step.rawValue - 1) {
            step = prev
        }
    }

    private func savePlant() {
        let plant = Plant(
            id: UUID(),
            name: plantName.trimmingCharacters(in: .whitespaces),
            species: species.trimmingCharacters(in: .whitespaces),
            wateringInterval: wateringInterval,
            lastWatered: .now,
            lightNeeds: lightNeeds.rawValue,
            notes: notes.trimmingCharacters(in: .whitespaces),
            dateAdded: .now
        )
        onComplete(plant)
        dismiss()
    }
}

#if DEBUG
#Preview {
    AddPlantFlowView { plant in
        print("Added: \(plant.name)")
    }
}
#endif
