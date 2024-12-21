import SwiftUI

@MainActor
class InstanceDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var error: String?
    
    func performAction(_ action: InstanceAction, on instance: AWSResource) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch action {
            case .start:
                try await Task { @MainActor in
                    try await AWSManager.shared.startInstance(instanceId: instance.id)
                }.value
            case .stop:
                try await Task { @MainActor in
                    try await AWSManager.shared.stopInstance(instanceId: instance.id)
                }.value
            case .reboot:
                try await Task { @MainActor in
                    try await AWSManager.shared.rebootInstance(instanceId: instance.id)
                }.value
            case .terminate:
                try await Task { @MainActor in
                    try await AWSManager.shared.terminateInstance(instanceId: instance.id)
                }.value
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
} 