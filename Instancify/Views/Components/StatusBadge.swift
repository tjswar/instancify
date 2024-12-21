import SwiftUI

struct StatusBadge: View {
    let status: String
    
    var color: Color {
        switch status.lowercased() {
        case "running": return .green
        case "pending": return .orange
        case "stopping", "shutting-down": return .orange
        case "stopped": return .red
        case "terminated": return .gray
        default: return .secondary
        }
    }
    
    var body: some View {
        Text(status.capitalized)
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .cornerRadius(8)
    }
} 