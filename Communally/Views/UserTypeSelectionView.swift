//
//  UserTypeSelectionView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import GoogleSignIn

struct UserTypeSelectionView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    @State private var selectedUserType: UserType = .jobSeeker
    @State private var showOnboarding = false
    
    var body: some View {
        ZStack {
            CommunallyTheme.white
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Header
                VStack(spacing: 20) {
                    Text("Welcome to Communally!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                    
                    Text("How would you like to use Communally?")
                        .font(CommunallyTheme.subtitleFont)
                        .foregroundColor(Color.black)
                        .multilineTextAlignment(.center)
                }
                
                // User Type Selection
                VStack(spacing: 20) {
                    UserTypeCard(
                        title: "I'm Looking for Opportunities",
                        subtitle: "Find jobs and volunteer work near you",
                        icon: "person.fill",
                        isSelected: selectedUserType == .jobSeeker
                    ) {
                        selectedUserType = .jobSeeker
                    }
                    
                    UserTypeCard(
                        title: "I'm Offering Opportunities",
                        subtitle: "Post jobs and volunteer positions",
                        icon: "briefcase.fill",
                        isSelected: selectedUserType == .jobHirer
                    ) {
                        selectedUserType = .jobHirer
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button("Continue") {
                    updateUserType()
                    showOnboarding = true
                }
                .buttonStyle(CommunallyTheme.primaryButtonStyle)
                .padding(.horizontal, CommunallyTheme.padding)
            }
        }
        .fullScreenCover(isPresented: $showOnboarding) {
            if selectedUserType == .jobSeeker {
                JobSeekerOnboardingView()
                    .environmentObject(authManager)
            } else {
                JobHirerOnboardingView()
                    .environmentObject(authManager)
            }
        }
    }
    
    private func updateUserType() {
        guard let currentUser = authManager.currentUser else { return }
        
        let updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            firstName: currentUser.firstName,
            lastName: currentUser.lastName,
            age: currentUser.age,
            userType: selectedUserType,
            profileImageURL: currentUser.profileImageURL,
            profileImageData: currentUser.profileImageData,
            skills: currentUser.skills,
            description: currentUser.description,
            location: currentUser.location,
            createdAt: currentUser.createdAt,
            isParentalApproved: currentUser.isParentalApproved,
            hasCompletedOnboarding: currentUser.hasCompletedOnboarding
        )
        
        authManager.updateUser(updatedUser)
    }
}

struct UserTypeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 20) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(isSelected ? .white : CommunallyTheme.primaryGreen)
                    .frame(width: 50, height: 50)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.white.opacity(0.2) : CommunallyTheme.lightGray)
                    )
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(CommunallyTheme.subtitleFont)
                        .foregroundColor(isSelected ? .white : Color.black)
                        .multilineTextAlignment(.leading)
                    
                    Text(subtitle)
                        .font(CommunallyTheme.bodyFont)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : Color.black.opacity(0.7))
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding(20)
            .background(
                Group {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(CommunallyTheme.buttonGradient)
                    } else {
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                    }
                }
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    UserTypeSelectionView()
        .environmentObject(AuthenticationManager.shared)
}
