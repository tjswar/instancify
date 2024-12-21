import Foundation
import AWSCore

@MainActor
class LoginViewModel: ObservableObject {
    @Published var accessKeyId = ""
    @Published var secretKey = ""
    @Published var selectedRegion: AWSRegion = .usEast1
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let authManager = AuthenticationManager.shared
    
    func connect() async {
        isLoading = true
        errorMessage = nil
        
        guard !accessKeyId.isEmpty else {
            errorMessage = "Access Key ID is required"
            isLoading = false
            return
        }
        
        guard !secretKey.isEmpty else {
            errorMessage = "Secret Key is required"
            isLoading = false
            return
        }
        
        do {
            try await AWSManager.shared.configure(
                accessKey: accessKeyId,
                secretKey: secretKey,
                region: selectedRegion.toAWSRegionType()
            )
            authManager.isAuthenticated = true
        } catch let awsError as AWSError {
            errorMessage = awsError.errorDescription
        } catch {
            errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}

extension AWSRegion {
    func toAWSRegionType() -> AWSRegionType {
        switch self {
        case .usEast1: return .USEast1
        case .usEast2: return .USEast2
        case .usWest1: return .USWest1
        case .usWest2: return .USWest2
        case .euWest1: return .EUWest1
        case .euCentral1: return .EUCentral1
        case .apSoutheast1: return .APSoutheast1
        case .apSoutheast2: return .APSoutheast2
        }
    }
} 