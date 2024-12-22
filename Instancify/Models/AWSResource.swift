import Foundation

struct AWSResource: Identifiable {
    let id: String
    let name: String
    let status: String
    let type: AWSResourceType
    let instanceType: String?
    let launchTime: Date?
    let publicIP: String?
    let privateIP: String?
    
    init(id: String, name: String, status: String, type: AWSResourceType, instanceType: String? = nil, launchTime: Date? = nil, publicIP: String? = nil, privateIP: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.type = type
        self.instanceType = instanceType
        self.launchTime = launchTime
        self.publicIP = publicIP
        self.privateIP = privateIP
    }
    
    var runningTime: String {
        guard let launch = launchTime else { return "N/A" }
        let duration = Date().timeIntervalSince(launch)
        
        let hours = Int(floor(duration / 3600))
        let minutes = Int(floor(duration.truncatingRemainder(dividingBy: 3600) / 60))
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var details: [String: String] {
        var dict: [String: String] = [
            "Name": name,
            "Status": status
        ]
        if let instanceType = instanceType {
            dict["Type"] = instanceType
        }
        return dict
    }
} 