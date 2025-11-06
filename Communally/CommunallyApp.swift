//
//  CommunallyApp.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import GoogleSignIn
import Foundation
import FirebaseCore

@main
struct CommunallyApp: App {
    @StateObject private var authManager = AuthenticationManager.shared
    
    init() {
        // Configure Firebase
        FirebaseApp.configure()
        print("✅ Firebase configured successfully")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}
