//
//  MessageManager.swift
//  Communally
//
//  Manages messaging between hirers and accepted applicants
//

import Foundation
import FirebaseFirestore
import Combine

class MessageManager: ObservableObject {
    static let shared = MessageManager()
    
    @Published var conversations: [Conversation] = []
    @Published var messages: [String: [Message]] = [:] // conversationId -> messages
    
    private let db = Firestore.firestore()
    private var conversationListener: ListenerRegistration?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    private init() {
        // Listeners started when user logs in
    }
    
    deinit {
        conversationListener?.remove()
        messageListeners.values.forEach { $0.remove() }
    }
    
    // MARK: - Start Listening
    
    func startListening(for userId: String) {
        print("📨 Starting message listener for user: \(userId)")
        
        // Listen to conversations where user is a participant
        conversationListener = db.collection("conversations")
            .whereField("participantIds", arrayContains: userId)
            .order(by: "lastMessageAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error listening to conversations: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    print("ℹ️ No conversations found")
                    return
                }
                
                self.conversations = documents.compactMap { doc -> Conversation? in
                    let data = doc.data()
                    
                    guard let opportunityId = data["opportunityId"] as? String,
                          let hirerId = data["hirerId"] as? String,
                          let hirerName = data["hirerName"] as? String,
                          let applicantId = data["applicantId"] as? String,
                          let applicantName = data["applicantName"] as? String,
                          let participantIds = data["participantIds"] as? [String],
                          let lastMessage = data["lastMessage"] as? String,
                          let lastMessageAtTimestamp = data["lastMessageAt"] as? Timestamp,
                          let createdAtTimestamp = data["createdAt"] as? Timestamp else {
                        return nil
                    }
                    
                    let hirerImageDataString = data["hirerImageData"] as? String
                    let hirerImageData = hirerImageDataString.flatMap { Data(base64Encoded: $0) }
                    
                    let applicantImageDataString = data["applicantImageData"] as? String
                    let applicantImageData = applicantImageDataString.flatMap { Data(base64Encoded: $0) }
                    
                    let unreadCount = data["unreadCount_\(userId)"] as? Int ?? 0
                    
                    return Conversation(
                        id: doc.documentID,
                        opportunityId: opportunityId,
                        hirerId: hirerId,
                        hirerName: hirerName,
                        hirerImageData: hirerImageData,
                        applicantId: applicantId,
                        applicantName: applicantName,
                        applicantImageData: applicantImageData,
                        participantIds: participantIds,
                        lastMessage: lastMessage,
                        lastMessageAt: lastMessageAtTimestamp.dateValue(),
                        unreadCount: unreadCount,
                        createdAt: createdAtTimestamp.dateValue()
                    )
                }
                
                print("✅ Synced \(self.conversations.count) conversations")
                
                // Start listening to messages for each conversation
                for conversation in self.conversations {
                    self.startListeningToMessages(conversationId: conversation.id)
                }
            }
    }
    
    func stopListening() {
        conversationListener?.remove()
        messageListeners.values.forEach { $0.remove() }
        messageListeners.removeAll()
        conversations.removeAll()
        messages.removeAll()
    }
    
    // MARK: - Messages
    
    private func startListeningToMessages(conversationId: String) {
        // Don't create duplicate listeners
        guard messageListeners[conversationId] == nil else { return }
        
        let listener = db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .order(by: "sentAt", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("❌ Error listening to messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.messages[conversationId] = documents.compactMap { doc -> Message? in
                    let data = doc.data()
                    
                    guard let senderId = data["senderId"] as? String,
                          let senderName = data["senderName"] as? String,
                          let text = data["text"] as? String,
                          let sentAtTimestamp = data["sentAt"] as? Timestamp else {
                        return nil
                    }
                    
                    return Message(
                        id: doc.documentID,
                        conversationId: conversationId,
                        senderId: senderId,
                        senderName: senderName,
                        text: text,
                        sentAt: sentAtTimestamp.dateValue()
                    )
                }
                
                print("✅ Synced \(self.messages[conversationId]?.count ?? 0) messages for conversation \(conversationId)")
            }
        
        messageListeners[conversationId] = listener
    }
    
    // MARK: - Create Conversation
    
    func createConversation(
        opportunityId: String,
        hirerId: String,
        hirerName: String,
        hirerImageData: Data?,
        applicantId: String,
        applicantName: String,
        applicantImageData: Data?
    ) async -> String? {
        // Check if conversation already exists
        if let existing = conversations.first(where: {
            $0.opportunityId == opportunityId &&
            $0.hirerId == hirerId &&
            $0.applicantId == applicantId
        }) {
            print("ℹ️ Conversation already exists: \(existing.id)")
            return existing.id
        }
        
        let conversationId = UUID().uuidString
        
        let conversationData: [String: Any] = [
            "opportunityId": opportunityId,
            "hirerId": hirerId,
            "hirerName": hirerName,
            "hirerImageData": hirerImageData?.base64EncodedString() ?? "",
            "applicantId": applicantId,
            "applicantName": applicantName,
            "applicantImageData": applicantImageData?.base64EncodedString() ?? "",
            "participantIds": [hirerId, applicantId],
            "lastMessage": "Chat created! Start discussing job details.",
            "lastMessageAt": Timestamp(date: Date()),
            "unreadCount_\(hirerId)": 0,
            "unreadCount_\(applicantId)": 0,
            "createdAt": Timestamp(date: Date())
        ]
        
        do {
            try await db.collection("conversations").document(conversationId).setData(conversationData)
            print("✅ Created conversation: \(conversationId)")
            return conversationId
        } catch {
            print("❌ Error creating conversation: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Send Message
    
    func sendMessage(conversationId: String, senderId: String, senderName: String, text: String) {
        let messageId = UUID().uuidString
        let now = Timestamp(date: Date())
        
        let messageData: [String: Any] = [
            "senderId": senderId,
            "senderName": senderName,
            "text": text,
            "sentAt": now
        ]
        
        // Add message to subcollection
        db.collection("conversations")
            .document(conversationId)
            .collection("messages")
            .document(messageId)
            .setData(messageData) { error in
                if let error = error {
                    print("❌ Error sending message: \(error.localizedDescription)")
                    return
                }
                
                print("✅ Message sent")
            }
        
        // Update conversation's last message
        guard let conversation = conversations.first(where: { $0.id == conversationId }) else { return }
        
        let otherUserId = conversation.participantIds.first { $0 != senderId } ?? ""
        
        db.collection("conversations")
            .document(conversationId)
            .updateData([
                "lastMessage": text,
                "lastMessageAt": now,
                "unreadCount_\(otherUserId)": FieldValue.increment(Int64(1))
            ])
    }
    
    // MARK: - Mark as Read
    
    func markAsRead(conversationId: String, userId: String) {
        db.collection("conversations")
            .document(conversationId)
            .updateData([
                "unreadCount_\(userId)": 0
            ])
    }
    
    // MARK: - Get Messages
    
    func getMessages(for conversationId: String) -> [Message] {
        return messages[conversationId] ?? []
    }
}

// MARK: - Models

struct Conversation: Identifiable, Codable {
    let id: String
    let opportunityId: String
    let hirerId: String
    let hirerName: String
    let hirerImageData: Data?
    let applicantId: String
    let applicantName: String
    let applicantImageData: Data?
    let participantIds: [String]
    let lastMessage: String
    let lastMessageAt: Date
    let unreadCount: Int
    let createdAt: Date
    
    func otherUserName(currentUserId: String) -> String {
        return currentUserId == hirerId ? applicantName : hirerName
    }
    
    func otherUserImageData(currentUserId: String) -> Data? {
        return currentUserId == hirerId ? applicantImageData : hirerImageData
    }
    
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: lastMessageAt, relativeTo: Date())
    }
}

struct Message: Identifiable, Codable {
    let id: String
    let conversationId: String
    let senderId: String
    let senderName: String
    let text: String
    let sentAt: Date
    
    var timeString: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: sentAt)
    }
}

