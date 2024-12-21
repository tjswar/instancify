import SwiftUI

struct FilteredInstancesView: View {
    let resources: [AWSResource]
    let status: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                if resources.isEmpty {
                    SharedEmptyStateView(
                        title: "No \(status) instances found"
                    )
                } else {
                    List(resources) { resource in
                        EC2InstanceRow(instance: resource)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("\(status.capitalized) Instances")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
} 