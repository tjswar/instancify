import SwiftUI

struct InstanceDetailView: View {
    let instance: AWSResource
    @StateObject private var viewModel = InstanceDetailViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingActionConfirmation = false
    @State private var selectedAction: InstanceAction?
    
    var body: some View {
        List {
            // Instance Details Section
            Text("Instance Details").font(.headline)
            DetailRow(label: "Name", value: instance.name)
            DetailRow(label: "ID", value: instance.id)
            DetailRow(label: "Type", value: instance.instanceType ?? "t2.micro")
            DetailRow(
                label: "Status",
                value: instance.status,
                trailing: StatusIndicator(status: instance.status)
            )
            
            // Actions Section
            Text("Actions").font(.headline)
            ForEach(InstanceAction.allCases) { action in
                Button(action: {
                    selectedAction = action
                    showingActionConfirmation = true
                }) {
                    HStack {
                        Image(systemName: action.icon)
                            .foregroundColor(action.color)
                        Text(action.title)
                    }
                }
                .disabled(!action.isEnabled(for: instance.status))
            }
            
            // Metrics Section
            Text("Metrics").font(.headline)
            MetricRow(label: "CPU Usage", value: "32%", icon: "cpu")
            MetricRow(label: "Memory", value: "2.1 GB", icon: "memorychip")
            MetricRow(label: "Network In", value: "1.2 MB/s", icon: "arrow.down.circle")
            MetricRow(label: "Network Out", value: "0.8 MB/s", icon: "arrow.up.circle")
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(instance.name)
        .alert("Confirm Action", isPresented: $showingActionConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button(selectedAction?.title ?? "", role: selectedAction?.destructive == true ? .destructive : .none) {
                if let action = selectedAction {
                    Task {
                        await viewModel.performAction(action, on: instance)
                        dismiss()
                    }
                }
            }
        } message: {
            if let action = selectedAction {
                Text("Are you sure you want to \(action.title.lowercased()) this instance?")
            }
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .disabled(viewModel.isLoading)
    }
}

enum InstanceAction: String, CaseIterable, Identifiable {
    case start, stop, reboot, terminate
    
    var id: String { rawValue }
    var title: String { rawValue.capitalized }
    var destructive: Bool { self == .terminate }
    
    var icon: String {
        switch self {
        case .start: return "play.circle.fill"
        case .stop: return "stop.circle.fill"
        case .reboot: return "arrow.clockwise.circle.fill"
        case .terminate: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .start: return .green
        case .stop: return .orange
        case .reboot: return .blue
        case .terminate: return .red
        }
    }
    
    func isEnabled(for status: String) -> Bool {
        switch self {
        case .start: return status == "stopped"
        case .stop: return status == "running"
        case .reboot: return status == "running"
        case .terminate: return status != "terminated"
        }
    }
} 