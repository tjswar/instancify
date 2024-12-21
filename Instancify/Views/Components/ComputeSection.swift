import SwiftUI

struct ComputeSection: View {
    let resourceCount: Int
    let onTap: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Compute")
                .font(.title3)
                .bold()
                .padding(.horizontal)
            
            ResourceCard(
                title: "EC2 Instances",
                count: resourceCount,
                icon: "server.rack",
                color: .blue,
                description: "Manage virtual servers"
            )
            .onTapGesture(perform: onTap)
        }
    }
}

#Preview {
    ComputeSection(resourceCount: 5) {}
        .padding()
} 