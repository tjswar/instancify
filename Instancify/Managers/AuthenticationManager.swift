import Foundation

class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @Published var isAuthenticated = false
    
    #if DEBUG
    init() {
        // Allow initialization for previews
    }
    #else
    private init() {
        // Private init for production
    }
    #endif
    
    func signOut() {
        isAuthenticated = false
    }
} 