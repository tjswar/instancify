import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedTab = 0
    
    var body: some View {
        if authManager.isAuthenticated {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    DashboardView()
                        .navigationTitle("Dashboard")
                }
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(0)
                
                NavigationStack {
                    SettingsView()
                        .navigationTitle("Settings")
                }
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
                .tag(1)
            }
        } else {
            LoginView()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthenticationManager.shared)
} 
