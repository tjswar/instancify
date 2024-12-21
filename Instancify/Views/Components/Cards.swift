import SwiftUI

struct ResourceCard: View {
    let title: String
    let count: Int
    let icon: String
    let color: Color
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(count)")
                    .font(.title3)
                    .bold()
                Text(count == 1 ? "resource" : "resources")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct StatCard: View {
    let count: Int
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button {
            HapticManager.impact(style: .medium)
            action()
        } label: {
            VStack {
                Text("\(count)")
                    .font(.system(.title, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(color)
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// Add a scale animation when tapped
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    VStack(spacing: 20) {
        ResourceCard(
            title: "EC2 Instances",
            count: 5,
            icon: "server.rack",
            color: .blue,
            description: "Manage virtual servers"
        )
        
        HStack {
            StatCard(count: 3, title: "Running", color: .green) {
                // Action for Running instances
            }
            StatCard(count: 2, title: "Stopped", color: .red) {
                // Action for Stopped instances
            }
        }
        .padding()
    }
    .preferredColorScheme(.light)
} 