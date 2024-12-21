import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @State private var selectedRegion = AWSRegion(rawValue: AWSManager.shared.currentConnectionDetails?.region ?? "us-east-1") ?? .usEast1
    @State private var isRefreshing = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Region Display
                Text(selectedRegion.displayName)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.vertical, 8)
                
                if isRefreshing {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.2)
                        Text("Updating resources...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                
                CostOverviewSection(viewModel: viewModel)
                    .padding(.bottom, 8)
                
                QuickActionsSection(viewModel: viewModel, onActionComplete: {
                    // Show loading and refresh after action completes
                    withAnimation {
                        isRefreshing = true
                    }
                    // Add a delay to allow AWS to update instance states
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                        Task {
                            await refreshDashboard()
                        }
                    }
                })
                .padding(.bottom, 8)
                
                StatsSection(viewModel: viewModel)
                    .padding(.bottom, 8)
                
                ServicesSection(viewModel: viewModel)
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                RegionSwitcherView(currentRegion: selectedRegion) { newRegion in
                    try await viewModel.switchRegion(to: newRegion)
                    selectedRegion = newRegion
                }
            }
        }
        .refreshable {
            await refreshDashboard()
        }
        .task {
            await refreshDashboard()
        }
    }
    
    private func refreshDashboard() async {
        withAnimation {
            isRefreshing = true
        }
        await viewModel.fetchResources()
        withAnimation {
            isRefreshing = false
        }
    }
}

struct StatsSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    @State private var showingFilteredInstances = false
    @State private var selectedFilter: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Resources Overview")
                .font(.headline)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                StatCard(
                    count: viewModel.runningCount,
                    title: "Running",
                    color: .green
                ) {
                    selectedFilter = "running"
                    showingFilteredInstances = true
                }
                
                StatCard(
                    count: viewModel.stoppedCount,
                    title: "Stopped",
                    color: .red
                ) {
                    selectedFilter = "stopped"
                    showingFilteredInstances = true
                }
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingFilteredInstances) {
            FilteredInstancesView(
                resources: viewModel.resources.filter { 
                    $0.type == .ec2 && 
                    $0.status.lowercased() == selectedFilter 
                },
                status: selectedFilter ?? ""
            )
        }
    }
}

struct ServicesSection: View {
    @ObservedObject var viewModel: DashboardViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Services")
                .font(.headline)
                .padding(.horizontal)
            
            LazyVStack(spacing: 12) {
                NavigationLink(destination: EC2InstancesView()) {
                    ServiceRowView(
                        service: .ec2,
                        resourceCount: viewModel.getResourceCount(for: .ec2)
                    )
                }
            }
            .padding(.horizontal)
        }
    }
} 
#Preview {
    DashboardView()
}
