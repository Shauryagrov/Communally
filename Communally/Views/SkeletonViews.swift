//
//  SkeletonViews.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI

// Skeleton loading views for better UX
struct OpportunityCardSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header skeleton
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CommunallyTheme.lightGray.opacity(0.3))
                        .frame(width: 120, height: 16)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(CommunallyTheme.lightGray.opacity(0.3))
                        .frame(width: 80, height: 12)
                }
                
                Spacer()
                
                Circle()
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 20, height: 20)
            }
            
            // Description skeleton
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(height: 14)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 200, height: 14)
            }
            
            // Location skeleton
            HStack {
                Circle()
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 12, height: 12)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 100, height: 12)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 60, height: 12)
            }
            
            // Skills skeleton
            HStack(spacing: 8) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(CommunallyTheme.lightGray.opacity(0.3))
                        .frame(width: 60, height: 20)
                }
                
                Spacer()
            }
            
            // Hirer info skeleton
            HStack(spacing: 8) {
                Circle()
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 24, height: 24)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 80, height: 12)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 40, height: 12)
            }
            
            // Action buttons skeleton
            HStack {
                Circle()
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 24, height: 24)
                
                Spacer()
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 80, height: 32)
            }
        }
        .padding(CommunallyTheme.padding)
        .background(Color.white)
        .cornerRadius(CommunallyTheme.cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

struct ConversationSkeleton: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar skeleton
            Circle()
                .fill(CommunallyTheme.lightGray.opacity(0.3))
                .frame(width: 48, height: 48)
            
            VStack(alignment: .leading, spacing: 8) {
                // Name skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 120, height: 16)
                
                // Last message skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 200, height: 14)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                // Time skeleton
                RoundedRectangle(cornerRadius: 4)
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 40, height: 12)
                
                // Unread indicator skeleton
                Circle()
                    .fill(CommunallyTheme.lightGray.opacity(0.3))
                    .frame(width: 16, height: 16)
            }
        }
        .padding(CommunallyTheme.padding)
        .background(Color.white)
        .cornerRadius(CommunallyTheme.cornerRadius)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
        .opacity(isAnimating ? 0.5 : 1.0)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        OpportunityCardSkeleton()
        ConversationSkeleton()
    }
    .padding()
}
