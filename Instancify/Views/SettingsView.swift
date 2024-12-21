import SwiftUI
import AWSCore

struct SettingsView: View {
    @AppStorage("accessKeyId") private var accessKeyId = ""
    @State private var secretKey = ""
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingSuccessAlert = false
    @State private var showingSignOutAlert = false
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        NavigationView {
            Form {
                Section("AWS Credentials") {
                    TextField("Access Key ID", text: $accessKeyId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Secret Access Key", text: $secretKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section {
                    Button(action: {
                        Task {
                            await saveCredentials()
                        }
                    }) {
                        if isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                        } else {
                            Text("Save Credentials")
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(accessKeyId.isEmpty || secretKey.isEmpty || isLoading)
                }
                
                Section {
                    Button(role: .destructive) {
                        showingSignOutAlert = true
                    } label: {
                        Text("Sign Out")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Error", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .alert("Success", isPresented: $showingSuccessAlert) {
                Button("OK") { }
            } message: {
                Text("AWS credentials have been saved successfully.")
            }
            .alert("Sign Out", isPresented: $showingSignOutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Sign Out", role: .destructive) {
                    Task {
                        try? await AWSManager.shared.clearConfiguration()
                        authManager.signOut()
                    }
                }
            } message: {
                Text("Are you sure you want to sign out? This will clear all saved credentials.")
            }
        }
    }
    
    private func saveCredentials() async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AWSManager.shared.configure(
                accessKey: accessKeyId,
                secretKey: secretKey,
                region: .USEast1 // Default to US East 1
            )
            showingSuccessAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    NavigationView {
        SettingsView()
            .environmentObject(AuthenticationManager.shared)
    }
} 