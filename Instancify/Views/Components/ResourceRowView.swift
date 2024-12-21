import SwiftUI

struct ResourceRowView: View {
    let resource: AWSResource
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(resource.name)
                .font(.headline)
            if !resource.details.isEmpty {
                HStack {
                    if let type = resource.instanceType {
                        Text(type)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                    StatusBadge(status: resource.status)
                }
            }
        }
        .padding(.vertical, 4)
    }
} 