import SwiftUI

struct EC2InstanceRow: View {
    let instance: AWSResource
    
    var body: some View {
        NavigationLink {
            InstanceDetailView(instance: instance)
        } label: {
            VStack(alignment: .leading) {
                Text(instance.name)
                    .font(.headline)
                HStack {
                    Text(instance.instanceType ?? "")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    if instance.status.lowercased() == "running" {
                        Text("• \(instance.runningTime)")
                            .font(.subheadline)
                            .foregroundColor(.green)
                    }
                    Spacer()
                    StatusBadge(status: instance.status)
                }
            }
            .padding(.vertical, 4)
        }
    }
} 