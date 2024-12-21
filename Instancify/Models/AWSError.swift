import Foundation

enum AWSError: LocalizedError {
    case notConfigured
    case invalidCredentials
    case invalidRegion
    case requestFailed
    case configurationFailed
    case serviceError(String)
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "AWS is not configured"
        case .invalidCredentials:
            return "Invalid AWS credentials"
        case .invalidRegion:
            return "Invalid AWS region"
        case .requestFailed:
            return "Failed to create AWS request"
        case .configurationFailed:
            return "Failed to create AWS configuration"
        case .serviceError(let message):
            return message
        }
    }
} 