//
//  UserDatabase.swift
//  Communally
//
//  Persistent storage for all users
//

import Foundation

class UserDatabase {
    static let shared = UserDatabase()
    
    private let usersKey = "allUsers"
    
    private init() {}
    
    // Get user by Google ID
    func getUser(byGoogleId googleId: String) -> User? {
        let allUsers = getAllUsers()
        return allUsers.first { $0.id == googleId }
    }
    
    // Get user by email
    func getUser(byEmail email: String) -> User? {
        let allUsers = getAllUsers()
        return allUsers.first { $0.email == email }
    }
    
    // Save or update user
    func saveUser(_ user: User) {
        var allUsers = getAllUsers()
        
        // Remove existing user with same ID if exists
        allUsers.removeAll { $0.id == user.id }
        
        // Add updated user
        allUsers.append(user)
        
        // Save to UserDefaults
        if let encodedData = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(encodedData, forKey: usersKey)
            print("💾 UserDatabase: Saved user \(user.fullName) (Total users: \(allUsers.count))")
        }
    }
    
    // Get all users
    func getAllUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    // Delete user
    func deleteUser(byId id: String) {
        var allUsers = getAllUsers()
        allUsers.removeAll { $0.id == id }
        
        if let encodedData = try? JSONEncoder().encode(allUsers) {
            UserDefaults.standard.set(encodedData, forKey: usersKey)
            print("🗑️ UserDatabase: Deleted user with ID \(id)")
        }
    }
    
    // Clear all users (for testing)
    func clearAll() {
        UserDefaults.standard.removeObject(forKey: usersKey)
        print("🗑️ UserDatabase: Cleared all users")
    }
}

