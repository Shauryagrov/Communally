//
//  PlaceholderViews.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    @State private var showAccountView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                CommunallyTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Profile Header
                        VStack(spacing: 16) {
                            // Use uploaded profile image instead of Google profile picture
                            Group {
                                if let profileImageData = authManager.currentUser?.profileImageData,
                                   let uiImage = UIImage(data: profileImageData) {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                } else {
                                    // Default profile image if no custom image uploaded
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 80))
                                        .foregroundColor(CommunallyTheme.primaryGreen)
                                }
                            }
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 4)
                            )
                            .overlay(
                                Circle()
                                    .stroke(CommunallyTheme.primaryGreen, lineWidth: 2)
                            )
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            
                            VStack(spacing: 8) {
                                Text("\(authManager.currentUser?.firstName ?? "") \(authManager.currentUser?.lastName ?? "")")
                                    .font(CommunallyTheme.titleFont)
                                    .fontWeight(.bold)
                                    .foregroundColor(CommunallyTheme.darkGray)
                                
                                Text(authManager.currentUser?.userType == .jobSeeker ? "Job Seeker" : "Job Hirer")
                                    .font(CommunallyTheme.bodyFont)
                                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                                
                                // Age display
                                if let age = authManager.currentUser?.age {
                                    Text("Age: \(age)")
                                        .font(CommunallyTheme.captionFont)
                                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 4)
                                        .background(
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(CommunallyTheme.primaryGreen.opacity(0.1))
                                        )
                                }
                            }
                            
                            // Bio section
                            if let description = authManager.currentUser?.description, !description.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("About Me")
                                        .font(CommunallyTheme.subtitleFont)
                                        .fontWeight(.semibold)
                                        .foregroundColor(CommunallyTheme.darkGray)
                                    
                                    Text(description)
                                        .font(CommunallyTheme.bodyFont)
                                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.8))
                                        .multilineTextAlignment(.leading)
                                        .lineLimit(nil)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.white.opacity(0.8))
                                )
                            }
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        // Quick Actions
                        VStack(spacing: 12) {
                            Button(action: {
                                showAccountView = true
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "person.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(CommunallyTheme.primaryGreen)
                                    
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Account")
                                            .font(CommunallyTheme.subtitleFont)
                                            .fontWeight(.semibold)
                                            .foregroundColor(CommunallyTheme.darkGray)
                                        
                                        Text("Manage your profile and settings")
                                            .font(CommunallyTheme.captionFont)
                                            .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.4))
                                }
                                .padding(16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Sign Out Button
                            Button(action: {
                                authManager.signOut()
                                dismiss()
                            }) {
                                Text("Sign Out")
                                    .font(CommunallyTheme.bodyFont)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: CommunallyTheme.buttonHeight)
                                    .background(CommunallyTheme.buttonGradient)
                                    .cornerRadius(CommunallyTheme.cornerRadius)
                            }
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(CommunallyTheme.padding)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAccountView) {
                AccountView()
                    .environmentObject(authManager)
            }
        }
    }
}

struct AccountView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                CommunallyTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Account Management Options
                        VStack(spacing: 12) {
                            ProfileOptionRow(icon: "person.fill", title: "Edit Profile", action: {})
                            ProfileOptionRow(icon: "bookmark.fill", title: "Saved Posts", action: {})
                            ProfileOptionRow(icon: "clock.fill", title: "Applied Posts", action: {})
                            ProfileOptionRow(icon: "bell.fill", title: "Notifications", action: {})
                            ProfileOptionRow(icon: "lock.fill", title: "Privacy & Security", action: {})
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        // App Settings
                        VStack(spacing: 12) {
                            ProfileOptionRow(icon: "gear", title: "Settings", action: {})
                            ProfileOptionRow(icon: "questionmark.circle", title: "Help & Support", action: {})
                            ProfileOptionRow(icon: "info.circle", title: "About", action: {})
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(CommunallyTheme.padding)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle("Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CommunallyTheme.primaryGreen)
                }
            }
        }
    }
}

struct ProfileOptionRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(CommunallyTheme.primaryGreen)
                    .frame(width: 24)
                
                Text(title)
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(CommunallyTheme.darkGray)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
            }
            .padding(.vertical, 12)
        }
    }
}

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                CommunallyTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // App Logo and Info
                        VStack(spacing: 16) {
                            Image("CommunallyLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                            
                            Text("Communally")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(CommunallyTheme.darkGray)
                            
                            Text("Connect locally. Help globally.")
                                .font(CommunallyTheme.subtitleFont)
                                .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        // App Info
                        VStack(alignment: .leading, spacing: 16) {
                            Text("About Communally")
                                .font(CommunallyTheme.subtitleFont)
                                .fontWeight(.semibold)
                                .foregroundColor(CommunallyTheme.darkGray)
                            
                            Text("Communally is a platform that connects people in their local community for jobs and volunteer opportunities. Whether you're looking for work or want to help others, Communally makes it easy to find meaningful connections in your area.")
                                .font(CommunallyTheme.bodyFont)
                                .foregroundColor(CommunallyTheme.darkGray.opacity(0.8))
                                .lineSpacing(4)
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        // Links
                        VStack(spacing: 12) {
                            AboutLinkRow(title: "Terms of Service", action: {})
                            AboutLinkRow(title: "Privacy Policy", action: {})
                            AboutLinkRow(title: "Contact Us", action: {})
                        }
                        .padding(CommunallyTheme.padding)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                    }
                    .padding(CommunallyTheme.padding)
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CommunallyTheme.primaryGreen)
                }
            }
        }
    }
}

struct AboutLinkRow: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
            }
            .padding(.vertical, 8)
        }
    }
}

struct NewPostView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                CommunallyTheme.backgroundGradient
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Create New Post")
                        .font(CommunallyTheme.titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(CommunallyTheme.darkGray)
                    
                    Text("This feature will be available soon!")
                        .font(CommunallyTheme.bodyFont)
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Spacer()
                }
                .padding(CommunallyTheme.padding)
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(CommunallyTheme.primaryGreen)
                }
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthenticationManager.shared)
}
