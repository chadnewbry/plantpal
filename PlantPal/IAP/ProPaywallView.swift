import SwiftUI

struct ProPaywallView: View {
    @ObservedObject private var proManager = PlantPalProManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var errorMessage: String?
    @State private var showError = false
    @State private var showRestoreSuccess = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.green)

                        Text("PlantPal Pro")
                            .font(.largeTitle.bold())

                        Text("One-time purchase. No subscriptions. Ever.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        FeatureRow(icon: "infinity", title: "Unlimited Plants", subtitle: "Track your entire collection")
                        FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Advanced Analytics", subtitle: "Health trends and watering insights")
                        FeatureRow(icon: "bell.badge.fill", title: "Smart Reminders", subtitle: "Custom notification schedules")
                        FeatureRow(icon: "camera.fill", title: "Plant Journal", subtitle: "Photo timeline for each plant")
                        FeatureRow(icon: "applewatch", title: "Watch Companion", subtitle: "Quick care from your wrist")
                        FeatureRow(icon: "widget.small", title: "Home Screen Widgets", subtitle: "At-a-glance plant status")
                    }
                    .padding(.horizontal)

                    // Purchase Button
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                do {
                                    try await proManager.purchasePro()
                                    dismiss()
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        } label: {
                            HStack {
                                if proManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("Get PlantPal Pro — $6.99")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.green)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                        }
                        .disabled(proManager.isLoading)

                        Button("Restore Purchase") {
                            Task {
                                do {
                                    try await proManager.restorePurchases()
                                    if proManager.isPro {
                                        showRestoreSuccess = true
                                    } else {
                                        errorMessage = "No previous purchase found."
                                        showError = true
                                    }
                                } catch {
                                    errorMessage = error.localizedDescription
                                    showError = true
                                }
                            }
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .disabled(proManager.isLoading)
                    }
                    .padding(.horizontal)

                    Text("One-time purchase. Pay once, yours forever.\nNo sneaky subscriptions.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 32)
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .alert("Error", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(errorMessage ?? "Something went wrong.")
            }
            .alert("Restored!", isPresented: $showRestoreSuccess) {
                Button("OK") { dismiss() }
            } message: {
                Text("PlantPal Pro has been restored successfully.")
            }
        }
    }
}

private struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.green)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#if DEBUG
#Preview {
    ProPaywallView()
}
#endif
