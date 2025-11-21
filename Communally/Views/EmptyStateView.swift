//
//  EmptyStateView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let actionTitle: String
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: 24) {
                ZStack {
                    // Outer glow
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.8, blue: 0.9).opacity(0.3),
                                    Color(red: 0.6, green: 0.7, blue: 1.0).opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)
                    
                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.8, blue: 0.9),
                                    Color(red: 0.6, green: 0.7, blue: 1.0)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(red: 0.5, green: 0.8, blue: 0.9).opacity(0.4), radius: 15, x: 0, y: 8)
                    
                Image(systemName: "magnifyingglass")
                        .font(.system(size: 48, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.15, green: 0.15, blue: 0.15))
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(.system(size: 16, weight: .regular, design: .rounded))
                        .foregroundColor(Color(red: 0.45, green: 0.45, blue: 0.45))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 24)
                }
            }
            
            VStack(spacing: 14) {
                Button(action: {
                    let impactMed = UIImpactFeedbackGenerator(style: .medium)
                    impactMed.impactOccurred()
                    action()
                }) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 16, weight: .semibold))
                        
                    Text(actionTitle)
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                    }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.5, green: 0.8, blue: 0.9),
                                        Color(red: 0.6, green: 0.7, blue: 1.0)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(color: Color(red: 0.5, green: 0.8, blue: 0.9).opacity(0.4), radius: 15, x: 0, y: 8)
                    )
                }
                
                Button(action: {
                    let impactLight = UIImpactFeedbackGenerator(style: .light)
                    impactLight.impactOccurred()
                    // Reset filters action
                }) {
                    Text("Reset Filters")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.5, green: 0.8, blue: 0.9))
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                        .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            LinearGradient(
                                                colors: [
                                                    Color(red: 0.5, green: 0.8, blue: 0.9),
                                                    Color(red: 0.6, green: 0.7, blue: 1.0)
                                                ],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            ),
                                            lineWidth: 2
                                        )
                                )
                                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
                        )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(24)
    }
}

#Preview {
    EmptyStateView(
        title: "No opportunities near you",
        message: "No opportunities near you right now. Try widening your radius or check back later.",
        actionTitle: "Refresh",
        action: {}
    )
}
