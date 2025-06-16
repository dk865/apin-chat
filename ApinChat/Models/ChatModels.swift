import Foundation
import SwiftUI

struct Chat: Identifiable, Codable {
    var id: UUID
    var title: String
    var messages: [Message]
    var createdAt: Date
    var updatedAt: Date
    
    init(id: UUID = UUID(), title: String = "New Chat", messages: [Message] = [], 
         createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    var lastMessage: String {
        messages.last?.content ?? "No messages"
    }
    
    var isEmpty: Bool {
        messages.isEmpty
    }
}

struct Message: Identifiable, Codable {
    var id: UUID
    var content: String
    var isUser: Bool
    var timestamp: Date
    var isProcessing: Bool
    
    init(id: UUID = UUID(), content: String, isUser: Bool, 
         timestamp: Date = Date(), isProcessing: Bool = false) {
        self.id = id
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.isProcessing = isProcessing
    }
}

enum AIModelType: String, CaseIterable, Identifiable, Codable {
    case conversation = "Conversation"
    case creative = "Creative"
    case precise = "Precise"
    
    var id: String { self.rawValue }
    
    var description: String {
        switch self {
        case .conversation: return "Balanced for everyday conversations"
        case .creative: return "More creative and expressive responses"
        case .precise: return "Focused on accuracy and facts"
        }
    }
    
    var systemPrompt: String {
        switch self {
        case .conversation: 
            return "You are Apin, a helpful AI assistant. Respond conversationally and be concise."
        case .creative:
            return "You are Apin, a creative AI assistant. Feel free to be imaginative, expressive, and think outside the box."
        case .precise:
            return "You are Apin, a precise AI assistant. Focus on accuracy, facts, and clear information."
        }
    }
}