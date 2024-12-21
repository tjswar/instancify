import Foundation
import AWSCore

class AWSService {
    static let shared = AWSService()
    private let manager = AWSManager.shared
    
    func configure(with connection: AWSConnection) async throws {
        let awsRegion: AWSRegionType
        switch connection.region {
        case "us-east-1": awsRegion = .USEast1
        case "us-east-2": awsRegion = .USEast2
        case "us-west-1": awsRegion = .USWest1
        case "us-west-2": awsRegion = .USWest2
        case "eu-west-1": awsRegion = .EUWest1
        case "eu-central-1": awsRegion = .EUCentral1
        case "ap-southeast-1": awsRegion = .APSoutheast1
        case "ap-southeast-2": awsRegion = .APSoutheast2
        case "ap-northeast-1": awsRegion = .APNortheast1
        default: throw AWSError.invalidRegion
        }
        
        try await manager.configure(
            accessKey: connection.accessKeyId,
            secretKey: connection.secretKey,
            region: awsRegion
        )
    }
    
    func fetchResources() async throws -> [AWSResource] {
        try await manager.fetchResourcesAcrossRegions()
    }
    
    func fetchResourcesAcrossRegions() async throws -> [AWSResource] {
        try await manager.fetchResourcesAcrossRegions()
    }
} 