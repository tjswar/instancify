import SwiftUI
import AWSCore
import AWSEC2

struct ServiceSettingsView: View {
    @AppStorage("awsServiceConfig") private var configData: Data = try! JSONEncoder().encode(AWSServiceConfig.default)
    @State private var config = AWSServiceConfig.default
    @State private var selectedRegion: AWSRegion = .usEast1
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let regions: [AWSRegion] = AWSRegion.allCases
    
    var body: some View {
        Form {
            Section(header: Text("Region")) {
                Picker("Region", selection: $selectedRegion) {
                    ForEach(regions, id: \.self) { region in
                        Text(region.displayName).tag(region)
                    }
                }
                .onChange(of: selectedRegion, initial: false) { oldValue, newValue in
                    Task {
                        try await AWSManager.shared.switchRegion(newValue.rawValue)
                    }
                }
            }
            
            Section(header: Text("AWS Services")) {
                ForEach(AWSServiceType.allCases, id: \.self) { service in
                    Toggle(service.rawValue.uppercased(), isOn: Binding(
                        get: { config.isServiceEnabled(service) },
                        set: { _ in config.toggleService(service) }
                    ))
                }
            }
        }
        .navigationTitle("Service Settings")
        .onAppear {
            if let decoded = try? JSONDecoder().decode(AWSServiceConfig.self, from: configData) {
                config = decoded
            }
        }
        .onChange(of: config.enabledServices, initial: false) { oldValue, newValue in
            if let encoded = try? JSONEncoder().encode(config) {
                configData = encoded
            }
        }
        .overlay {
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
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
    }
    
    private func switchRegion(to region: String) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            try await AWSManager.shared.switchRegion(region)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    ServiceSettingsView()
} 