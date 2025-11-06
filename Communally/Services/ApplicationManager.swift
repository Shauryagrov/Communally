//
//  ApplicationManager.swift
//  Communally
//
//  Manages job applications and workflow
//

import Foundation
import SwiftUI

class ApplicationManager: ObservableObject {
    static let shared = ApplicationManager()
    
    @Published var applications: [JobApplication] = []
    
    private let applicationsKey = "savedApplications"
    
    private init() {
        loadApplications()
    }
    
    private func loadApplications() {
        guard let data = UserDefaults.standard.data(forKey: applicationsKey),
              let decoded = try? JSONDecoder().decode([JobApplication].self, from: data) else {
            print("ℹ️ No saved applications found")
            return
        }
        applications = decoded
        print("✅ Loaded \(decoded.count) applications from storage")
    }
    
    private func saveApplications() {
        guard let encoded = try? JSONEncoder().encode(applications) else {
            print("❌ Failed to encode applications")
            return
        }
        UserDefaults.standard.set(encoded, forKey: applicationsKey)
        print("💾 Saved \(applications.count) applications to storage")
    }
    
    // Submit application
    func applyToOpportunity(opportunityId: String, applicantId: String, applicantName: String, applicantImageData: Data?) {
        // Check if already applied
        if hasApplied(opportunityId: opportunityId, applicantId: applicantId) {
            print("⚠️ User already applied to this opportunity")
            return
        }
        
        let application = JobApplication(
            id: UUID().uuidString,
            opportunityId: opportunityId,
            applicantId: applicantId,
            applicantName: applicantName,
            applicantImageData: applicantImageData,
            status: .pending,
            appliedAt: Date(),
            message: nil
        )
        
        applications.append(application)
        saveApplications()
        
        // Update opportunity applicant count
        OpportunityManager.shared.incrementApplicantCount(opportunityId: opportunityId)
        
        print("✅ Application submitted by \(applicantName)")
        print("📊 Total applications: \(applications.count)")
    }
    
    // Check if user already applied
    func hasApplied(opportunityId: String, applicantId: String) -> Bool {
        return applications.contains { 
            $0.opportunityId == opportunityId && $0.applicantId == applicantId
        }
    }
    
    // Get applications for specific opportunity
    func getApplications(forOpportunity opportunityId: String) -> [JobApplication] {
        return applications.filter { $0.opportunityId == opportunityId }
    }
    
    // Get pending applications for opportunity
    func getPendingApplications(forOpportunity opportunityId: String) -> [JobApplication] {
        return applications.filter { 
            $0.opportunityId == opportunityId && $0.status == .pending 
        }
    }
    
    // Get applications by user
    func getApplications(byUser userId: String) -> [JobApplication] {
        return applications.filter { $0.applicantId == userId }
    }
    
    // Accept application (hirer chooses someone)
    func acceptApplication(applicationId: String) {
        guard let index = applications.firstIndex(where: { $0.id == applicationId }) else {
            return
        }
        
        let application = applications[index]
        let opportunityId = application.opportunityId
        
        // Update this application to accepted
        applications[index].status = .accepted
        applications[index].acceptedAt = Date()
        
        // Reject all other pending applications for this opportunity
        for i in 0..<applications.count {
            if applications[i].opportunityId == opportunityId && 
               applications[i].id != applicationId && 
               applications[i].status == .pending {
                applications[i].status = .rejected
            }
        }
        
        saveApplications()
        
        // Update opportunity status to in progress
        OpportunityManager.shared.updateOpportunityStatus(
            opportunityId: opportunityId, 
            status: .inProgress,
            acceptedApplicantId: application.applicantId
        )
        
        print("✅ Application accepted for opportunity \(opportunityId)")
        print("❌ Other applications rejected")
    }
    
    // Complete job (hirer confirms done)
    func completeJob(opportunityId: String) {
        // Mark opportunity as completed
        OpportunityManager.shared.updateOpportunityStatus(
            opportunityId: opportunityId,
            status: .completed,
            acceptedApplicantId: nil
        )
        
        // Update application status
        if let index = applications.firstIndex(where: { 
            $0.opportunityId == opportunityId && $0.status == .accepted 
        }) {
            applications[index].status = .completed
            applications[index].completedAt = Date()
            saveApplications()
        }
        
        print("✅ Job completed for opportunity \(opportunityId)")
    }
    
    // Cancel application
    func cancelApplication(applicationId: String) {
        if let index = applications.firstIndex(where: { $0.id == applicationId }) {
            applications[index].status = .cancelled
            saveApplications()
        }
    }
}

// MARK: - Models

struct JobApplication: Identifiable, Codable {
    let id: String
    let opportunityId: String
    let applicantId: String
    let applicantName: String
    let applicantImageData: Data?
    var status: ApplicationStatus
    let appliedAt: Date
    var acceptedAt: Date?
    var completedAt: Date?
    let message: String?
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: appliedAt, relativeTo: Date())
    }
}

enum ApplicationStatus: String, Codable {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case completed = "completed"
    case cancelled = "cancelled"
}

