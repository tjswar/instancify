import SwiftUI

@MainActor
class InstanceDetailViewModel: ObservableObject {
    @Published var instance: AWSResource?
    @Published var isLoading = false
    @Published var error: String?
    
    // Cost calculations
    @Published var hourlyRate: Double = 0.0
    @Published var currentCost: Double = 0.0
    @Published var projectedDailyCost: Double = 0.0
    
    private let instanceHourlyRates: [String: Double] = [
        "t2.micro": 0.0116,
        "t2.small": 0.023,
        "t2.medium": 0.0464,
        "t2.large": 0.0928,
        "t3.micro": 0.0104,
        "t3.small": 0.0208,
        "t3.medium": 0.0416,
        "t3.large": 0.0832
    ]
    
    func fetchInstanceDetails(instanceId: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            let resources = try await AWSManager.shared.fetchResources()
            if let instance = resources.first(where: { $0.id == instanceId }) {
                self.instance = instance
                calculateCosts(for: instance)
            }
        } catch {
            self.error = error.localizedDescription
        }
    }
    
    private func calculateCosts(for instance: AWSResource) {
        guard let instanceType = instance.instanceType,
              let rate = instanceHourlyRates[instanceType],
              let launchTime = instance.launchTime,
              instance.status.lowercased() == "running" else {
            hourlyRate = 0
            currentCost = 0
            projectedDailyCost = 0
            return
        }
        
        hourlyRate = rate
        let runningHours = Date().timeIntervalSince(launchTime) / 3600.0
        currentCost = rate * runningHours
        projectedDailyCost = rate * 24
    }
    
    func performAction(_ action: InstanceAction, on instance: AWSResource) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch action {
            case .start:
                try await AWSManager.shared.startInstance(instanceId: instance.id)
            case .stop:
                try await AWSManager.shared.stopInstance(instanceId: instance.id)
            case .reboot:
                try await AWSManager.shared.rebootInstance(instanceId: instance.id)
            case .terminate:
                try await AWSManager.shared.terminateInstance(instanceId: instance.id)
            }
            
            // Wait for AWS to process the request
            try? await Task.sleep(nanoseconds: 3_000_000_000)
            await fetchInstanceDetails(instanceId: instance.id)
            HapticManager.notification(type: .success)
        } catch {
            self.error = error.localizedDescription
            HapticManager.notification(type: .error)
        }
    }
} 