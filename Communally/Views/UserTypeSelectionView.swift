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
    @State private var animateCards = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.95, green: 0.98, blue: 0.92),
                    Color.white,
                    Color(red: 0.97, green: 1.0, blue: 0.94)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
                .ignoresSafeArea()
            
            // Decorative circles
            Circle()
                .fill(CommunallyTheme.primaryGreen.opacity(0.05))
                .frame(width: 300, height: 300)
                .offset(x: -150, y: -200)
                .blur(radius: 40)
            
            Circle()
                .fill(CommunallyTheme.secondaryGreen.opacity(0.05))
                .frame(width: 250, height: 250)
                .offset(x: 180, y: 300)
                .blur(radius: 40)
            
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)
                
                // App Logo or Icon
                ZStack {
                    Circle()
                        .fill(CommunallyTheme.buttonGradient)
                        .frame(width: 100, height: 100)
                        .shadow(color: CommunallyTheme.primaryGreen.opacity(0.3), radius: 20, x: 0, y: 10)
                    
                    Image(systemName: "hands.sparkles.fill")
                        .font(.system(size: 45, weight: .semibold))
                        .foregroundColor(.white)
                }
                .scaleEffect(animateCards ? 1.0 : 0.8)
                .opacity(animateCards ? 1.0 : 0.0)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: animateCards)
                
                Spacer()
                    .frame(height: 40)
                
                // Header
                VStack(spacing: 12) {
                    Text("Welcome to Communally!")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [CommunallyTheme.primaryGreen, CommunallyTheme.secondaryGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .multilineTextAlignment(.center)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2), value: animateCards)
                    
                    Text("How would you like to use Communally?")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.3, blue: 0.3))
                        .multilineTextAlignment(.center)
                        .opacity(animateCards ? 1.0 : 0.0)
                        .offset(y: animateCards ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: animateCards)
                }
                .padding(.horizontal, 30)
                
                Spacer()
                    .frame(height: 50)
                
                // User Type Selection
                VStack(spacing: 16) {
                    UserTypeCard(
                        title: "I'm Looking for Opportunities",
                        subtitle: "Find jobs and volunteer work near you",
                        icon: "person.fill",
                        isSelected: selectedUserType == .jobSeeker,
                        animateIn: animateCards
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedUserType = .jobSeeker
                        }
                    }
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(x: animateCards ? 0 : -50)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4), value: animateCards)
                    
                    UserTypeCard(
                        title: "I'm Offering Opportunities",
                        subtitle: "Post jobs and volunteer positions",
                        icon: "briefcase.fill",
                        isSelected: selectedUserType == .jobHirer,
                        animateIn: animateCards
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedUserType = .jobHirer
                        }
                    }
                    .opacity(animateCards ? 1.0 : 0.0)
                    .offset(x: animateCards ? 0 : 50)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: animateCards)
                }
                .padding(.horizontal, 24)
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    updateUserType()
                    showOnboarding = true
                }) {
                    HStack(spacing: 12) {
                        Text("Continue")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                        
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 30)
                            .fill(CommunallyTheme.buttonGradient)
                            .shadow(color: CommunallyTheme.primaryGreen.opacity(0.4), radius: 20, x: 0, y: 10)
                    )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .opacity(animateCards ? 1.0 : 0.0)
                .offset(y: animateCards ? 0 : 30)
                .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: animateCards)
            }
        }
        .onAppear {
            animateCards = true
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
    let animateIn: Bool
    let action: () -> Void
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            let impactLight = UIImpactFeedbackGenerator(style: .light)
            impactLight.impactOccurred()
            action()
        }) {
            HStack(spacing: 18) {
                // Icon
                ZStack {
                    // Glow effect when selected
                    if isSelected {
                        Circle()
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .blur(radius: 8)
                    }
                    
                    Circle()
                        .fill(isSelected ? Color.white.opacity(0.25) : CommunallyTheme.primaryGreen.opacity(0.1))
                        .frame(width: 60, height: 60)
                        .overlay(
                            Circle()
                                .strokeBorder(
                                    isSelected ? Color.white.opacity(0.4) : CommunallyTheme.primaryGreen.opacity(0.3),
                                    lineWidth: 2
                                )
                        )
                    
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundColor(isSelected ? .white : CommunallyTheme.primaryGreen)
                }
                
                // Text Content
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundColor(isSelected ? .white : Color(red: 0.15, green: 0.15, blue: 0.15))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(isSelected ? .white.opacity(0.9) : Color(red: 0.4, green: 0.4, blue: 0.4))
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Selection Indicator
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.white : Color(red: 0.85, green: 0.85, blue: 0.85),
                            lineWidth: 2.5
                        )
                        .frame(width: 28, height: 28)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 16, height: 16)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(CommunallyTheme.primaryGreen)
                    }
                }
            }
            .padding(24)
            .background(
                ZStack {
                    if isSelected {
                        // Selected state - gradient
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        CommunallyTheme.primaryGreen,
                                        CommunallyTheme.secondaryGreen
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: CommunallyTheme.primaryGreen.opacity(0.4), radius: 20, x: 0, y: 10)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    } else {
                        // Unselected state - white card
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                CommunallyTheme.primaryGreen.opacity(0.2),
                                                CommunallyTheme.secondaryGreen.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 2
                                    )
                            )
                            .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 5)
                    }
                }
            )
        }
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}

#Preview {
    UserTypeSelectionView()
        .environmentObject(AuthenticationManager.shared)
}
