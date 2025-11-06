//
//  OpportunityDetailView.swift
//  Communally
//
//  Detail view for opportunities with apply/manage options
//

import SwiftUI
import MapKit

struct OpportunityDetailView: View {
    let opportunity: Opportunity
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authManager: AuthenticationManager
    @ObservedObject private var applicationManager = ApplicationManager.shared
    @ObservedObject private var opportunityManager = OpportunityManager.shared
    
    @State private var showingApplicants = false
    @State private var showingCompletionConfirm = false
    
    private var isHirer: Bool {
        authManager.currentUser?.id == opportunity.hirerId
    }
    
    private var hasApplied: Bool {
        guard let userId = authManager.currentUser?.id else { return false }
        return applicationManager.hasApplied(opportunityId: opportunity.safeId, applicantId: userId)
    }
    
    private var pendingApplications: [JobApplication] {
        applicationManager.getPendingApplications(forOpportunity: opportunity.safeId)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection
                
                // Status Badge
                statusBadge
                
                // Pay Info
                payInfoSection
                
                // Description
                descriptionSection
                
                // Location
                locationSection
                
                // Applications (for hirer)
                if isHirer && opportunity.status == .open {
                    applicationsSection
                }
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 100)
            }
            .padding(20)
        }
        .background(CommunallyTheme.backgroundGradient.ignoresSafeArea())
        .navigationTitle("Opportunity Details")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingApplicants) {
            ApplicantsListView(opportunity: opportunity)
        }
        .alert("Complete Job?", isPresented: $showingCompletionConfirm) {
            Button("Cancel", role: .cancel) {}
            Button("Complete & Pay") {
                completeJob()
            }
        } message: {
            if opportunity.isVolunteer {
                Text("Mark this volunteer opportunity as completed?")
            } else {
                Text("Mark as completed and process payment of \(opportunity.displayPay)?")
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: iconForJobType(opportunity.jobType))
                .font(.system(size: 32))
                .foregroundColor(CommunallyTheme.primaryGreen)
                .frame(width: 60, height: 60)
                .background(CommunallyTheme.primaryGreen.opacity(0.1))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 6) {
                Text(opportunity.title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(CommunallyTheme.darkGray)
                
                Text(opportunity.jobType)
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                
                Text("Posted \(opportunity.timeAgo)")
                    .font(CommunallyTheme.captionFont)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.5))
            }
            
            Spacer()
        }
    }
    
    // MARK: - Status Badge
    private var statusBadge: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(opportunity.statusColor)
                .frame(width: 10, height: 10)
            
            Text(opportunity.statusDisplay)
                .font(CommunallyTheme.bodyFont)
                .fontWeight(.semibold)
                .foregroundColor(opportunity.statusColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(opportunity.statusColor.opacity(0.1))
        .cornerRadius(20)
    }
    
    // MARK: - Pay Info Section
    private var payInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Compensation")
                .font(CommunallyTheme.titleFont)
                .fontWeight(.bold)
                .foregroundColor(CommunallyTheme.darkGray)
            
            HStack {
                Image(systemName: opportunity.isVolunteer ? "heart.fill" : "dollarsign.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(opportunity.isVolunteer ? .red : CommunallyTheme.primaryGreen)
                
                Text(opportunity.displayPay)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(CommunallyTheme.darkGray)
                
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Description Section
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Description")
                .font(CommunallyTheme.titleFont)
                .fontWeight(.bold)
                .foregroundColor(CommunallyTheme.darkGray)
            
            Text(opportunity.description)
                .font(CommunallyTheme.bodyFont)
                .foregroundColor(CommunallyTheme.darkGray.opacity(0.8))
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Location Section
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Location")
                .font(CommunallyTheme.titleFont)
                .fontWeight(.bold)
                .foregroundColor(CommunallyTheme.darkGray)
            
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 20))
                    .foregroundColor(CommunallyTheme.primaryGreen)
                
                Text(opportunity.locationName)
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(CommunallyTheme.darkGray)
                
                Spacer()
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
        }
    }
    
    // MARK: - Applications Section
    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Applications")
                    .font(CommunallyTheme.titleFont)
                    .fontWeight(.bold)
                    .foregroundColor(CommunallyTheme.darkGray)
                
                Spacer()
                
                Text("\(opportunity.applicantCount)")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(CommunallyTheme.primaryGreen)
                    .cornerRadius(16)
            }
            
            if pendingApplications.isEmpty {
                Text("No applications yet")
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .cornerRadius(12)
            } else {
                Button(action: {
                    showingApplicants = true
                }) {
                    HStack {
                        Text("View \(pendingApplications.count) Applicant\(pendingApplications.count == 1 ? "" : "s")")
                            .font(CommunallyTheme.bodyFont)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(CommunallyTheme.darkGray)
                    .padding(16)
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
            }
        }
    }
    
    // MARK: - Action Buttons
    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !isHirer && opportunity.status == .open && !hasApplied {
                // Apply button for job seekers
                Button(action: applyToJob) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .font(.system(size: 20))
                        
                        Text("Apply for This Job")
                            .font(CommunallyTheme.bodyFont)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(CommunallyTheme.primaryGreen)
                    .cornerRadius(12)
                    .shadow(color: CommunallyTheme.primaryGreen.opacity(0.3), radius: 12, x: 0, y: 6)
                }
            } else if !isHirer && hasApplied {
                // Already applied
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(CommunallyTheme.primaryGreen)
                    
                    Text("Application Submitted")
                        .font(CommunallyTheme.bodyFont)
                        .fontWeight(.semibold)
                        .foregroundColor(CommunallyTheme.darkGray)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(CommunallyTheme.primaryGreen.opacity(0.1))
                .cornerRadius(12)
            }
            
            if isHirer && opportunity.status == .inProgress {
                // Complete job button
                Button(action: {
                    showingCompletionConfirm = true
                }) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        
                        Text(opportunity.isVolunteer ? "Mark as Complete" : "Complete & Pay")
                            .font(CommunallyTheme.bodyFont)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.blue)
                    .cornerRadius(12)
                    .shadow(color: Color.blue.opacity(0.3), radius: 12, x: 0, y: 6)
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    private func iconForJobType(_ type: String) -> String {
        switch type.lowercased() {
        case "gardening": return "leaf.fill"
        case "pet care": return "pawprint.fill"
        case "tutoring": return "book.fill"
        case "moving help": return "box.truck.fill"
        case "painting": return "paintbrush.fill"
        case "babysitting": return "figure.2.and.child.holdinghands"
        case "event help": return "calendar.badge.plus"
        case "cleaning": return "sparkles"
        case "delivery": return "shippingbox.fill"
        default: return "briefcase.fill"
        }
    }
    
    private func applyToJob() {
        guard let user = authManager.currentUser else { return }
        
        applicationManager.applyToOpportunity(
            opportunityId: opportunity.safeId,
            applicantId: user.id,
            applicantName: user.fullName,
            applicantImageData: user.profileImageData
        )
        
        print("✅ Applied to job: \(opportunity.title)")
    }
    
    private func completeJob() {
        applicationManager.completeJob(opportunityId: opportunity.safeId)
        
        // TODO: Process payment through Stripe here
        if !opportunity.isVolunteer {
            print("💰 Payment of \(opportunity.displayPay) would be processed here")
        }
        
        dismiss()
    }
}

#Preview {
    NavigationView {
        OpportunityDetailView(opportunity: Opportunity(
            id: "1",
            title: "Gardening Needed",
            description: "Need help with lawn mowing and weeding",
            hirerId: "hirer123",
            location: Location(latitude: 37.7749, longitude: -122.4194, address: "San Francisco"),
            locationName: "San Francisco, CA",
            isVolunteer: false,
            payAmount: "50",
            jobType: "Gardening",
            createdAt: Date(),
            isActive: true,
            applicantCount: 3,
            status: .open,
            acceptedApplicantId: nil
        ))
    }
    .environmentObject(AuthenticationManager.shared)
}

