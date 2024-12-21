import SwiftUI

struct ConnectAWSView: View {
    @StateObject private var viewModel = ConnectAWSViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("AWS Credentials")) {
                    TextField("Access Key ID", text: $viewModel.accessKeyId)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    SecureField("Secret Access Key", text: $viewModel.secretKey)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                
                Section(header: Text("Region")) {
                    Picker("Region", selection: $viewModel.selectedRegion) {
                        ForEach(AWSRegion.allCases) { region in
                            Text(region.displayName)
                                .tag(region)
                        }
                    }
                }
            }
            .navigationTitle("Connect AWS")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Connect") {
                        Task {
                            do {
                                try await viewModel.validateAndConnect()
                                dismiss()
                            } catch {
                                // Error is handled by the view model
                            }
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") {
                    viewModel.error = nil
                }
            } message: {
                if let error = viewModel.error {
                    Text(error)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
        }
    }
}

#Preview {
    ConnectAWSView()
} 