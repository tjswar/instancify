import Foundation

struct AWSCredentials: Codable {
    let accessKeyId: String
    let secretAccessKey: String
    let region: String
} 