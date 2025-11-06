//
//  User.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import Foundation

enum UserType: String, CaseIterable, Codable {
    case jobSeeker = "job_seeker"
    case jobHirer = "job_hirer"
}

enum UserAgeGroup: String, Codable {
    case teen = "teen" // 13-17
    case adult = "adult" // 18+
}

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let firstName: String
    let lastName: String
    let age: Int
    let userType: UserType
    let profileImageURL: String?
    let profileImageData: Data? // Store the actual image data
    let skills: [String]
    let description: String?
    let location: Location?
    let createdAt: Date
    let isParentalApproved: Bool?
    let hasCompletedOnboarding: Bool
    
    var ageGroup: UserAgeGroup {
        return age >= 18 ? .adult : .teen
    }
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
}

struct Location: Codable {
    let latitude: Double
    let longitude: Double
    let address: String?
}

struct JobOpportunity: Identifiable, Codable {
    let id: String
    let title: String
    let description: String
    let hirerId: String
    let location: Location
    let isVolunteer: Bool
    let skillsRequired: [String]
    let createdAt: Date
    let isActive: Bool
}

struct Conversation: Identifiable, Codable {
    let id: String
    let participants: [String] // User IDs
    let otherUser: User // The other participant (not current user)
    let lastMessage: String
    let lastMessageAt: Date
    let unreadCount: Int
    let createdAt: Date
}