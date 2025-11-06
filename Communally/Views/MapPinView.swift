//
//  MapPinView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import MapKit

struct MapPinView: View {
    let opportunity: JobOpportunity
    @State private var showPreview = false
    
    var body: some View {
        VStack(spacing: 4) {
            Button(action: {
                showPreview.toggle()
            }) {
                Image(systemName: opportunity.isVolunteer ? "heart.fill" : "briefcase.fill")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 30, height: 30)
                    .background(CommunallyTheme.buttonGradient)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }
            
            if showPreview {
                PinPreviewCard(opportunity: opportunity)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showPreview)
    }
}

struct PinPreviewCard: View {
    let opportunity: JobOpportunity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(opportunity.title)
                    .font(CommunallyTheme.captionFont)
                    .fontWeight(.semibold)
                    .foregroundColor(CommunallyTheme.darkGray)
                    .lineLimit(1)
                
                Spacer()
                
                Text(opportunity.isVolunteer ? "Volunteer" : "Job")
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(CommunallyTheme.buttonGradient)
                    .cornerRadius(4)
            }
            
            Text(opportunity.description)
                .font(.caption2)
                .foregroundColor(CommunallyTheme.darkGray.opacity(0.8))
                .lineLimit(2)
            
            HStack {
                ForEach(opportunity.skillsRequired.prefix(2), id: \.self) { skill in
                    Text(skill)
                        .font(.caption2)
                        .foregroundColor(CommunallyTheme.primaryGreen)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(CommunallyTheme.primaryGreen.opacity(0.1))
                        .cornerRadius(4)
                }
                
                if opportunity.skillsRequired.count > 2 {
                    Text("+\(opportunity.skillsRequired.count - 2)")
                        .font(.caption2)
                        .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                }
                
                Spacer()
            }
            
            HStack(spacing: 8) {
                Button(action: {
                    // View Details action
                }) {
                    Text("View Details")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(CommunallyTheme.buttonGradient)
                        .cornerRadius(6)
                }
                
                Button(action: {
                    // Message action
                }) {
                    Text("Message")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(CommunallyTheme.primaryGreen)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.white)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(CommunallyTheme.primaryGreen, lineWidth: 1)
                        )
                }
                
                Spacer()
            }
        }
        .padding(8)
        .frame(width: 200)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    MapPinView(opportunity: JobOpportunity(
        id: "1",
        title: "Retail Assistant",
        description: "Help customers and maintain store appearance",
        hirerId: "hirer1",
        location: Location(latitude: 37.7749, longitude: -122.4194, address: "Downtown Store"),
        isVolunteer: false,
        skillsRequired: ["Customer Service", "Retail"],
        createdAt: Date(),
        isActive: true
    ))
}
