//
//  InstancifyApp.swift
//  Instancify
//
//  Created by Dalli Sai Tejaswar Reddy on 12/10/24.
//

import SwiftUI
import AWSCore
import AWSEC2
import AWSS3
import AWSDynamoDB

@main
struct InstancifyApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    init() {
        // Set up AWS logging
        AWSDDLog.sharedInstance.logLevel = .verbose
        AWSDDLog.add(AWSDDTTYLogger.sharedInstance)
        
        // Set up a default AWS configuration
        let defaultConfig = AWSServiceConfiguration(
            region: .USEast1,
            credentialsProvider: AWSAnonymousCredentialsProvider()
        )!
        
        // Set default configuration globally
        AWSServiceManager.default().defaultServiceConfiguration = defaultConfig
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .preferredColorScheme(.light)
                .tint(.blue)
        }
    }
}
