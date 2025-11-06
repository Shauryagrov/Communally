//
//  MessagingView.swift
//  Communally
//
//  Created by Madhur Grover on 10/2/25.
//

import SwiftUI
import GoogleSignIn

struct MessagingView: View {
    @State private var conversations: [Conversation] = []
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        ZStack {
            CommunallyTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Text("Messages")
                        .font(CommunallyTheme.titleFont)
                        .foregroundColor(CommunallyTheme.darkGray)
                    
                    Spacer()
                    
                    Button(action: {
                        // Start new conversation
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(CommunallyTheme.primaryGreen)
                    }
                }
                .padding(.horizontal, CommunallyTheme.padding)
                .padding(.top, 10)
                
                if conversations.isEmpty {
                    // Empty state
                    VStack(spacing: 20) {
                        Image(systemName: "message")
                            .font(.system(size: 60))
                            .foregroundColor(CommunallyTheme.primaryGreen)
                        
                        Text("No messages yet")
                            .font(CommunallyTheme.subtitleFont)
                            .foregroundColor(CommunallyTheme.darkGray)
                        
                        Text("Start a conversation with someone you've connected with")
                            .font(CommunallyTheme.bodyFont)
                            .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                            .multilineTextAlignment(.center)
                        
                        Button("Find Opportunities") {
                            // Navigate to opportunities
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(CommunallyTheme.buttonGradient)
                        .cornerRadius(CommunallyTheme.cornerRadius)
                    }
                    .padding(CommunallyTheme.padding)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Conversations list
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(conversations) { conversation in
                                ConversationRow(conversation: conversation) {
                                    selectedConversation = conversation
                                }
                            }
                        }
                        .padding(CommunallyTheme.padding)
                    }
                }
            }
        }
        .sheet(item: $selectedConversation) { conversation in
            ChatView(conversation: conversation)
        }
    }
}


struct ConversationRow: View {
    let conversation: Conversation
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // Profile image
                Circle()
                    .fill(CommunallyTheme.lightGray)
                    .frame(width: 50, height: 50)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(CommunallyTheme.primaryGreen)
                    )
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(conversation.otherUser.fullName)
                            .font(CommunallyTheme.bodyFont)
                            .fontWeight(.semibold)
                            .foregroundColor(CommunallyTheme.darkGray)
                        
                        Spacer()
                        
                        Text(conversation.lastMessageAt, style: .time)
                            .font(CommunallyTheme.captionFont)
                            .foregroundColor(CommunallyTheme.darkGray.opacity(0.7))
                    }
                    
                    HStack {
                        Text(conversation.lastMessage)
                            .font(CommunallyTheme.captionFont)
                            .foregroundColor(CommunallyTheme.darkGray.opacity(0.8))
                            .lineLimit(1)
                        
                        Spacer()
                        
                        if conversation.unreadCount > 0 {
                            Text("\(conversation.unreadCount)")
                                .font(CommunallyTheme.captionFont)
                                .foregroundColor(.white)
                                .frame(minWidth: 20, minHeight: 20)
                                .background(CommunallyTheme.primaryGreen)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            .padding(CommunallyTheme.smallPadding)
            .background(CommunallyTheme.white)
            .cornerRadius(CommunallyTheme.cornerRadius)
            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
    }
}

struct ChatView: View {
    let conversation: Conversation
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Messages
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                        }
                    }
                    .padding(CommunallyTheme.padding)
                }
                
                // Message input
                HStack(spacing: 12) {
                    TextField("Type a message...", text: $messageText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(CommunallyTheme.buttonGradient)
                            .clipShape(Circle())
                    }
                    .disabled(messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(CommunallyTheme.padding)
                .background(CommunallyTheme.white)
            }
            .navigationTitle(conversation.otherUser.fullName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func sendMessage() {
        let message = Message(
            id: UUID().uuidString,
            text: messageText,
            senderId: "current_user", // This would be the current user's ID
            timestamp: Date(),
            isFromCurrentUser: true
        )
        
        messages.append(message)
        messageText = ""
    }
}

struct Message: Identifiable {
    let id: String
    let text: String
    let senderId: String
    let timestamp: Date
    let isFromCurrentUser: Bool
}

struct MessageBubble: View {
    let message: Message
    
    var body: some View {
        HStack {
            if message.isFromCurrentUser {
                Spacer()
            }
            
            VStack(alignment: message.isFromCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .font(CommunallyTheme.bodyFont)
                    .foregroundColor(message.isFromCurrentUser ? .white : CommunallyTheme.darkGray)
                    .padding(CommunallyTheme.smallPadding)
                    .background(
                        message.isFromCurrentUser ? 
                        AnyView(CommunallyTheme.buttonGradient) : 
                        AnyView(CommunallyTheme.lightGray)
                    )
                    .cornerRadius(CommunallyTheme.cornerRadius)
                
                Text(message.timestamp, style: .time)
                    .font(CommunallyTheme.captionFont)
                    .foregroundColor(CommunallyTheme.darkGray.opacity(0.6))
            }
            
            if !message.isFromCurrentUser {
                Spacer()
            }
        }
    }
}

#Preview {
    MessagingView()
}
