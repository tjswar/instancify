import SwiftUI

enum InstanceAction: String {
    case start = "Start Instance"
    case stop = "Stop Instance"
    case reboot = "Reboot Instance"
    case terminate = "Terminate Instance"
    
    var icon: String {
        switch self {
        case .start: return "play.circle.fill"
        case .stop: return "stop.circle.fill"
        case .reboot: return "arrow.clockwise.circle.fill"
        case .terminate: return "xmark.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .start: return .green
        case .stop: return .orange
        case .reboot: return .blue
        case .terminate: return .red
        }
    }
    
    var confirmationMessage: String {
        switch self {
        case .start: return "Are you sure you want to start this instance?"
        case .stop: return "Are you sure you want to stop this instance?"
        case .reboot: return "Are you sure you want to reboot this instance?"
        case .terminate: return "Warning: This action cannot be undone. Are you sure you want to terminate this instance?"
        }
    }
} 