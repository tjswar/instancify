import SwiftUI

struct EC2InstancesView: View {
    @StateObject private var viewModel = ServiceDetailViewModel(serviceType: .ec2)
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
            } else if viewModel.resources.isEmpty {
                SharedEmptyStateView(
                    title: "No EC2 instances found",
                    subtitle: "Create an EC2 instance in AWS Console to see it here"
                )
            } else {
                List {
                    Section(header: Text("Current Activity")) {
                        let runningInstances = viewModel.resources.filter { 
                            $0.status.lowercased() == "running" &&
                            $0.id != "error" && 
                            $0.id != "empty"
                        }
                        if runningInstances.isEmpty {
                            Text("No active instances")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(runningInstances) { instance in
                                NavigationLink {
                                    InstanceDetailView(instance: instance)
                                } label: {
                                    EC2InstanceRow(instance: instance)
                                }
                            }
                        }
                    }
                    
                    Section(header: Text("Recent Activity")) {
                        let stoppedInstances = viewModel.resources.filter { 
                            $0.status.lowercased() != "running" &&
                            $0.id != "error" && 
                            $0.id != "empty"
                        }
                        if stoppedInstances.isEmpty {
                            Text("No recent activity")
                                .foregroundColor(.secondary)
                        } else {
                            ForEach(stoppedInstances) { instance in
                                NavigationLink {
                                    InstanceDetailView(instance: instance)
                                } label: {
                                    EC2InstanceRow(instance: instance)
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("EC2 Instances")
        .task {
            print("Fetching EC2 instances...")
            await viewModel.fetchResources()
            print("Found \(viewModel.resources.count) EC2 instances")
        }
    }
} 