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
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 60))
                    .foregroundColor(CommunallyTheme.primaryGreen.opacity(0.6))
                
                VStack(spacing: 12) {
                    Text(title)
                        .font(CommunallyTheme.titleFont)
                        .fontWeight(.bold)
                        .foregroundColor(CommunallyTheme.darkGray)
                        .multilineTextAlignment(.center)
                    
                    Text(message)
                        .font(CommunallyTheme.bodyFont)
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            VStack(spacing: 16) {
                Button(action: action) {
                    Text(actionTitle)
                        .font(CommunallyTheme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: CommunallyTheme.buttonHeight)
                        .background(CommunallyTheme.buttonGradient)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                }
                
                Button(action: {
                    // Reset filters action
                }) {
                    Text("Reset Filters")
                        .font(CommunallyTheme.bodyFont)
                        .fontWeight(.medium)
                        .foregroundColor(CommunallyTheme.primaryGreen)
                        .frame(maxWidth: .infinity)
                        .frame(height: CommunallyTheme.buttonHeight)
                        .background(Color.white)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: CommunallyTheme.cornerRadius)
                                .stroke(CommunallyTheme.primaryGreen, lineWidth: 1)
                        )
                }
            }
            .padding(.horizontal, CommunallyTheme.padding)
            
            Spacer()
        }
        .padding(CommunallyTheme.padding)
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
