import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showConnectAWS = false
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Welcome to Instancify")
                .font(.largeTitle)
                .bold()
            
            Text("Let's connect your AWS account to get started")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button("Connect AWS") {
                showConnectAWS = true
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .sheet(isPresented: $showConnectAWS) {
            ConnectAWSView()
        }
        .onChange(of: appState.connections.count, initial: false) { _, newCount in
            if newCount > 0 {
                appState.completeOnboarding()
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState.shared)
} 