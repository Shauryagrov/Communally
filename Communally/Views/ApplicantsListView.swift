//
//  ApplicantsListView.swift
//  Communally
//
//  View for hirers to see and accept applicants
//

import SwiftUI

struct ApplicantsListView: View {
    let opportunity: Opportunity
    @Environment(\.dismiss) var dismiss
    @ObservedObject private var applicationManager = ApplicationManager.shared
    
    @State private var selectedApplicant: JobApplication?
    @State private var showingAcceptConfirm = false
    
    private var pendingApplications: [JobApplication] {
        applicationManager.getPendingApplications(forOpportunity: opportunity.safeId)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                CommunallyTheme.backgroundGradient.ignoresSafeArea()
                
                if pendingApplications.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(pendingApplications) { application in
                                ApplicantCard(application: application) {
                                    selectedApplicant = application
                                    showingAcceptConfirm = true
                                }
                            }
                        }
                        .padding(20)
                    }
                }
            }
            .navigationTitle("Applicants")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(CommunallyTheme.primaryGreen)
                }
            }
            .alert("Accept Applicant?", isPresented: $showingAcceptConfirm) {
                Button("Cancel", role: .cancel) {}
                Button("Accept") {
                    if let applicant = selectedApplicant {
                        acceptApplicant(applicant)
                    }
                }
            } message: {
                if let applicant = selectedApplicant {
                    Text("Accept \(applicant.applicantName) for this job? All other applications will be rejected.")
                }
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.2.slash")
                .font(.system(size: 60))
                .foregroundColor(CommunallyTheme.darkGray.opacity(0.3))
            
            Text("No Applications Yet")
                .font(CommunallyTheme.titleFont)
                .foregroundColor(CommunallyTheme.darkGray)
            
            Text("Check back later when people apply to your opportunity")
                .font(CommunallyTheme.bodyFont)
                .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
    
    private func acceptApplicant(_ application: JobApplication) {
        applicationManager.acceptApplication(applicationId: application.id)
        print("✅ Accepted applicant: \(application.applicantName)")
        dismiss()
    }
}

struct ApplicantCard: View {
    let application: JobApplication
    let onAccept: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile picture
            if let imageData = application.applicantImageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.3))
            }
            
            // Info
            VStack(alignment: .leading, spacing: 6) {
                Text(application.applicantName)
                    .font(CommunallyTheme.bodyFont)
                    .fontWeight(.bold)
                    .foregroundColor(CommunallyTheme.darkGray)
                
                Text("Applied \(application.timeAgo)")
                    .font(CommunallyTheme.captionFont)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
            }
            
            Spacer()
            
            // Accept button
            Button(action: onAccept) {
                Text("Accept")
                    .font(CommunallyTheme.captionFont)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(CommunallyTheme.primaryGreen)
                    .cornerRadius(20)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    ApplicantsListView(opportunity: Opportunity(
        id: "1",
        title: "Gardening Needed",
        description: "Need help with lawn mowing",
        hirerId: "hirer123",
        location: Location(latitude: 37.7749, longitude: -122.4194, address: "SF"),
        locationName: "San Francisco, CA",
        isVolunteer: false,
        payAmount: "50",
        jobType: "Gardening",
        createdAt: Date(),
        isActive: true,
        applicantCount: 2,
        status: .open,
        acceptedApplicantId: nil
    ))
}

