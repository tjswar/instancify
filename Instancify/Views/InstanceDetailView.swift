import SwiftUI

struct InstanceDetailView: View {
    let instance: AWSResource
    @StateObject private var viewModel = InstanceDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmation = false
    @State private var selectedAction: InstanceAction?
    @State private var autoRefreshTimer: Timer?
    
    var body: some View {
        List {
            // Instance Info Section
            Section {
                DetailRow(label: "Instance ID", value: instance.id)
                DetailRow(label: "Name", value: instance.name)
                DetailRow(label: "Type", value: instance.instanceType ?? "N/A")
                DetailRow(label: "Status", value: instance.status) {
                    StatusBadge(status: instance.status)
                }
                if let publicIP = instance.publicIP {
                    DetailRow(label: "Public IP", value: publicIP)
                }
                if let privateIP = instance.privateIP {
                    DetailRow(label: "Private IP", value: privateIP)
                }
            } header: {
                Label("Instance Details", systemImage: "server.rack")
            }
            
            // Runtime & Cost Section
            if instance.status.lowercased() == "running" {
                Section {
                    DetailRow(label: "Running Time", value: instance.runningTime)
                    DetailRow(label: "Hourly Rate", value: formatCurrency(viewModel.hourlyRate, decimals: 4))
                    DetailRow(label: "Current Cost", value: formatCurrency(viewModel.currentCost))
                    DetailRow(label: "Projected Daily", value: formatCurrency(viewModel.projectedDailyCost))
                } header: {
                    Label("Usage & Costs", systemImage: "chart.line.uptrend.xyaxis")
                }
            }
            
            // Actions Section
            Section {
                ForEach(getAvailableActions(), id: \.self) { action in
                    Button {
                        selectedAction = action
                        showingConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: action.icon)
                                .foregroundColor(action.color)
                                .frame(width: 30)
                            Text(action.rawValue)
                                .foregroundColor(action.color)
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            } header: {
                Label("Actions", systemImage: "gear")
            }
        }
        .navigationTitle("Instance Details")
        .refreshable {
            await viewModel.fetchInstanceDetails(instanceId: instance.id)
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.2)
                    .ignoresSafeArea()
                    .overlay {
                        VStack(spacing: 12) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Processing...")
                                .foregroundColor(.white)
                                .font(.subheadline)
                        }
                    }
            }
        }
        .alert("Confirm Action", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button(selectedAction?.rawValue ?? "", role: selectedAction == .terminate ? .destructive : .none) {
                Task {
                    await performAction()
                }
            }
        } message: {
            if let action = selectedAction {
                Text(action.confirmationMessage)
            }
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.error != nil },
            set: { if !$0 { viewModel.error = nil } }
        )) {
            Button("OK") { viewModel.error = nil }
        } message: {
            if let error = viewModel.error {
                Text(error)
            }
        }
        .task {
            await viewModel.fetchInstanceDetails(instanceId: instance.id)
        }
        .onAppear {
            // Start auto-refresh timer
            autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
                Task {
                    await viewModel.fetchInstanceDetails(instanceId: instance.id)
                }
            }
        }
        .onDisappear {
            // Clean up timer
            autoRefreshTimer?.invalidate()
            autoRefreshTimer = nil
        }
    }
    
    private var statusBackgroundColor: Color {
        switch instance.status.lowercased() {
        case "running": return Color.green.opacity(0.1)
        case "stopped": return Color.red.opacity(0.1)
        case "pending": return Color.orange.opacity(0.1)
        case "stopping": return Color.orange.opacity(0.1)
        default: return Color.clear
        }
    }
    
    private func getAvailableActions() -> [InstanceAction] {
        switch instance.status.lowercased() {
        case "running":
            return [.stop, .reboot, .terminate]
        case "stopped":
            return [.start, .terminate]
        case "stopping", "pending", "shutting-down":
            return []
        default:
            return [.terminate]
        }
    }
    
    private func performAction() async {
        guard let action = selectedAction else { return }
        await viewModel.performAction(action, on: instance)
        if action == .terminate {
            dismiss()
        }
    }
    
    private func formatCurrency(_ value: Double, decimals: Int = 2) -> String {
        return String(format: "$%.0\(decimals)f", value)
    }
}
 