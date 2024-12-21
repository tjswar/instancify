import SwiftUI

struct EC2Instance: Identifiable, Codable {
    let id: String
    let name: String
    let instanceType: String
    let state: InstanceState
    let publicIP: String?
    let privateIP: String
    let launchTime: Date
    
    var statusColor: Color {
        switch state {
        case .running: return .green
        case .stopped: return .red
        case .pending: return .orange
        case .stopping: return .orange
        case .terminated: return .gray
        }
    }
}

enum InstanceState: String, Codable {
    case running = "running"
    case stopped = "stopped"
    case pending = "pending"
    case stopping = "stopping"
    case terminated = "terminated"
} 