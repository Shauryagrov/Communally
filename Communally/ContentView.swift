//
//  ContentView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @ObservedObject private var authManager = AuthenticationManager.shared
    
    var body: some View {
        Group {
            if authManager.isAuthenticated {
                DashboardView()
                    .environmentObject(authManager)
                    .onAppear {
                        print("🏠 ContentView: Showing DashboardView")
                        print("🏠 ContentView: isAuthenticated = \(authManager.isAuthenticated)")
                        print("🏠 ContentView: currentUser = \(authManager.currentUser?.fullName ?? "nil")")
                    }
            } else {
                AuthenticationView()
                    .environmentObject(authManager)
                    .onAppear {
                        print("🔐 ContentView: Showing AuthenticationView")
                        print("🔐 ContentView: isAuthenticated = \(authManager.isAuthenticated)")
                        print("🔐 ContentView: currentUser = \(authManager.currentUser?.fullName ?? "nil")")
                    }
            }
        }
        .onReceive(authManager.$isAuthenticated) { isAuth in
            print("📡 ContentView: isAuthenticated changed to \(isAuth)")
        }
        .onReceive(authManager.$currentUser) { user in
            print("📡 ContentView: currentUser changed to \(user?.fullName ?? "nil")")
        }
    }
}

#Preview {
    ContentView()
}
