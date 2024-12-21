import Foundation
import Security

class KeychainManager {
    static let shared = KeychainManager()
    private let service = "tech.medilook.Instancify"
    
    private init() {}
    
    func storeCredentials(accessKey: String, secretKey: String, region: String) throws {
        let credentials = AWSCredentials(
            accessKeyId: accessKey,
            secretAccessKey: secretKey,
            region: region
        )
        let data = try JSONEncoder().encode(credentials)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecValueData as String: data
        ]
        
        SecItemDelete(query as CFDictionary)
        let status = SecItemAdd(query as CFDictionary, nil)
        
        guard status == errSecSuccess else {
            throw KeychainError.unableToStore
        }
    }
    
    func retrieveCredentials() throws -> AWSCredentials? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecReturnData as String: true
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let credentials = try? JSONDecoder().decode(AWSCredentials.self, from: data)
        else {
            return nil
        }
        
        return credentials
    }
    
    func clearCredentials() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unableToDelete
        }
    }
    
    func getSecretKey() throws -> String {
        guard let credentials = try retrieveCredentials() else {
            throw KeychainError.unableToRetrieve
        }
        return credentials.secretAccessKey
    }
}

enum KeychainError: Error {
    case unableToStore
    case unableToRetrieve
    case unableToDelete
} 