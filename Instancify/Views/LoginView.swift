import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AWS CREDENTIALS")) {
                    TextField("Access Key ID", text: $viewModel.accessKeyId)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                    
                    SecureField("Secret Access Key", text: $viewModel.secretKey)
                        .textContentType(.none)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("REGION")) {
                    Picker("AWS Region", selection: $viewModel.selectedRegion) {
                        ForEach(AWSRegion.allCases) { region in
                            Text(region.displayName).tag(region)
                        }
                    }
                }
                
                Section {
                    Button("Connect") {
                        Task {
                            await viewModel.connect()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Link("How to get AWS Access Keys", 
                         destination: URL(string: "https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey")!)
                    
                    Link("AWS Free Tier", 
                         destination: URL(string: "https://aws.amazon.com/free/")!)
                } header: {
                    Text("HELP")
                } footer: {
                    Text("Need AWS credentials? Sign up for AWS Free Tier to get started. Make sure to follow security best practices when handling your access keys.")
                }
            }
            .navigationTitle("Connect to AWS")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthenticationManager.shared)
} 