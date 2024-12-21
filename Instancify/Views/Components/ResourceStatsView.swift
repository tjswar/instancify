import SwiftUI

struct ResourceStatsView: View {
    let resources: [AWSResource]
    @State private var showingFilteredInstances = false
    @State private var selectedFilter: String?
    
    var body: some View {
        HStack(spacing: 20) {
            // Running Resources
            StatCard(
                count: resources.filter { $0.status.lowercased() == "running" }.count,
                title: "Running",
                color: .green
            ) {
                selectedFilter = "running"
                showingFilteredInstances = true
            }
            
            // Stopped Resources
            StatCard(
                count: resources.filter { $0.status.lowercased() == "stopped" }.count,
                title: "Stopped",
                color: .red
            ) {
                selectedFilter = "stopped"
                showingFilteredInstances = true
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $showingFilteredInstances) {
            FilteredInstancesView(
                resources: resources.filter { 
                    $0.status.lowercased() == selectedFilter 
                },
                status: selectedFilter ?? ""
            )
        }
    }
} 