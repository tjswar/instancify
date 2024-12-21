import Foundation

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var resources: [AWSResource] = []
    @Published var isLoading = false
    @Published var error: String?
    
    @Published var todayCost: Double = 0.0
    @Published var monthCost: Double = 0.0
    @Published var projectedCost: Double = 0.0
    
    // EC2 instance hourly rates (simplified example)
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
    
    var runningCount: Int {
        resources.filter { $0.status.lowercased() == "running" }.count
    }
    
    var stoppedCount: Int {
        resources.filter { $0.status.lowercased() == "stopped" }.count
    }
    
    func getResourceCount(for service: AWSResourceType) -> Int {
        resources.filter { $0.type == service }.count
    }
    
    func getResources(for serviceType: AWSResourceType) -> [AWSResource] {
        resources.filter { $0.type == serviceType }
    }
    
    func switchRegion(to region: AWSRegion) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AWSManager.shared.switchRegion(region.rawValue)
            await fetchResources()
        } catch {
            if let awsError = error as? AWSError {
                self.error = awsError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
            throw error
        }
    }
    
    private func calculateCosts() {
        var todayTotal: Double = 0
        var monthTotal: Double = 0
        var projectedTotal: Double = 0
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        
        for resource in resources {
            guard let instanceType = resource.instanceType,
                  let hourlyRate = instanceHourlyRates[instanceType],
                  let launchTime = resource.launchTime else { continue }
            
            if resource.status.lowercased() == "running" {
                // Calculate actual running hours
                let runningHours = now.timeIntervalSince(launchTime) / 3600.0
                
                // Today's cost - only count hours since start of day or launch time
                let startTime = max(startOfDay, launchTime)
                let todayHours = now.timeIntervalSince(startTime) / 3600.0
                todayTotal += hourlyRate * todayHours
                
                // Month's cost - only count hours since start of month or launch time
                let monthStartTime = max(startOfMonth, launchTime)
                let monthHours = now.timeIntervalSince(monthStartTime) / 3600.0
                monthTotal += hourlyRate * monthHours
                
                // Projected cost - based on current usage pattern
                let daysInMonth = Double(calendar.range(of: .day, in: .month, for: now)?.count ?? 30)
                let averageHoursPerDay = min(24.0, runningHours / max(1, Double(calendar.component(.day, from: launchTime))))
                projectedTotal += hourlyRate * (daysInMonth * averageHoursPerDay)
            }
        }
        
        DispatchQueue.main.async {
            self.todayCost = round(todayTotal * 100) / 100
            self.monthCost = round(monthTotal * 100) / 100
            self.projectedCost = round(projectedTotal * 100) / 100
            print("Costs calculated - Today: $\(self.todayCost), Month: $\(self.monthCost), Projected: $\(self.projectedCost)")
            print("Cost calculation details:")
            for resource in self.resources where resource.status.lowercased() == "running" {
                print("Instance \(resource.name) (\(resource.instanceType ?? "unknown"))")
                print("- Running time: \(resource.runningTime)")
                if let rate = self.instanceHourlyRates[resource.instanceType ?? ""] {
                    print("- Hourly rate: $\(rate)")
                }
            }
        }
    }
    
    func fetchResources() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            resources = try await AWSManager.shared.fetchResources()
            calculateCosts() // Calculate actual costs based on instance usage
        } catch {
            if let awsError = error as? AWSError {
                self.error = awsError.localizedDescription
            } else {
                self.error = error.localizedDescription
            }
        }
    }
    
    func stopAllInstances() async {
        guard !isLoading else { return }
        
        isLoading = true
        print("Starting stopAllInstances...")
        
        let runningInstances = resources.filter { 
            $0.type == .ec2 && 
            $0.status.lowercased() == "running" &&
            $0.id != "error" && 
            $0.id != "empty"
        }
        print("Found \(runningInstances.count) running instances")
        
        if runningInstances.isEmpty {
            self.error = "No running instances found"
            isLoading = false
            return
        }
        
        do {
            for instance in runningInstances {
                print("Attempting to stop instance: \(instance.id)")
                
                // Try up to 3 times
                for attempt in 1...3 {
                    do {
                        try await AWSManager.shared.stopInstance(instanceId: instance.id)
                        print("Stop request sent successfully for instance: \(instance.id)")
                        break
                    } catch {
                        if attempt == 3 {
                            throw error
                        }
                        print("Attempt \(attempt) failed, retrying...")
                        try await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay between retries
                    }
                }
            }
            
            // Wait for AWS to process the requests
            print("Waiting for instances to stop...")
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
            
            // Refresh the instance list
            print("Refreshing instance status...")
            await fetchResources()
            
            HapticManager.notification(type: .success)
        } catch {
            print("Stop operation failed: \(error.localizedDescription)")
            self.error = error.localizedDescription
            HapticManager.notification(type: .error)
        }
        
        isLoading = false
    }
    
    func refreshStatus() async {
        guard !isLoading else { return }
        
        isLoading = true
        print("Refreshing instance status...")
        await fetchResources()
        HapticManager.notification(type: .success)
        isLoading = false
    }
    
    func configureAutoStop() async {
        guard !isLoading else { return }
        
        isLoading = true
        print("Configuring auto-stop...")
        
        let runningInstances = resources.filter { 
            $0.type == .ec2 && $0.status.lowercased() == "running" 
        }
        
        if runningInstances.isEmpty {
            self.error = "No running instances found"
            isLoading = false
            return
        }
        
        self.error = "Auto-stop configuration will be available in a future update"
        HapticManager.notification(type: .warning)
        isLoading = false
    }
} 