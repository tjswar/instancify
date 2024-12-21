import SwiftUI

struct QuickActionsSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    let onActionComplete: () -> Void
    @State private var showingConfirmation = false
    @State private var selectedAction: BulkAction?
    @State private var showingError = false
    
    enum BulkAction: String {
        case stopAll = "Stop All"
        case refreshStatus = "Refresh Status"
        case setAutoStop = "Set Auto-Stop"
        
        var icon: String {
            switch self {
            case .stopAll: return "stop.circle.fill"
            case .refreshStatus: return "arrow.clockwise.circle.fill"
            case .setAutoStop: return "clock.circle.fill"
            }
        }
        
        var confirmationMessage: String {
            switch self {
            case .stopAll: return "Stop all running instances?"
            case .refreshStatus: return "Refresh status of all instances?"
            case .setAutoStop: return "Enable auto-stop for all instances?"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .padding(.horizontal)
            
            VStack(spacing: 12) {
                ForEach([BulkAction.stopAll, .refreshStatus, .setAutoStop], id: \.self) { action in
                    Button {
                        selectedAction = action
                        showingConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: action.icon)
                                .foregroundColor(viewModel.isLoading ? .gray : .accentColor)
                            Text(action.rawValue)
                                .foregroundColor(viewModel.isLoading ? .gray : .primary)
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
                        .padding(.vertical, 8)
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .alert("Confirm Action", isPresented: $showingConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                Task {
                    await performAction(selectedAction!)
                    onActionComplete()
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
    }
    
    private func performAction(_ action: BulkAction) async {
        switch action {
        case .stopAll:
            await viewModel.stopAllInstances()
        case .refreshStatus:
            await viewModel.fetchResources()
        case .setAutoStop:
            await viewModel.configureAutoStop()
        }
    }
} 