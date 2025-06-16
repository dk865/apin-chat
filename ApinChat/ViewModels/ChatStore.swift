import Foundation
import SwiftUI
import Combine
import Foundation

class ChatStore: ObservableObject {
    @Published var chats: [Chat] = []
    @Published var currentChat: Chat?
    @Published var selectedModelType: AIModelType = .conversation
    @Published var isProcessingResponse: Bool = false
    
    private let modelHandler = AIModelHandler()
    private let storageManager = StorageManager()
    
    init() {
        loadChats()
        if chats.isEmpty {
            createNewChat()
        } else {
            currentChat = chats.first
        }
    }
    
    func loadChats() {
        chats = storageManager.loadChats()
    }
    
    func saveChats() {
        storageManager.saveChats(chats)
    }
    
    func createNewChat() {
        let newChat = Chat(title: "New Chat")
        chats.append(newChat)
        currentChat = newChat
        saveChats()
    }
    
    func deleteChat(_ chat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats.remove(at: index)
        }
        
        if currentChat?.id == chat.id {
            currentChat = chats.first
        }
        
        saveChats()
    }
    
    func clearAllChats() {
        chats.removeAll()
        createNewChat()
        saveChats()
    }
    
    func updateChat(_ chat: Chat) {
        if let index = chats.firstIndex(where: { $0.id == chat.id }) {
            chats[index] = chat
            
            if currentChat?.id == chat.id {
                currentChat = chat
            }
        }
        saveChats()
    }
    
    func selectChat(_ chat: Chat) {
        currentChat = chat
    }
    
    func sendMessage(_ content: String) {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard var chat = currentChat else { return }
        
        let userMessage = Message(content: content, isUser: true)
        chat.messages.append(userMessage)
        
        // Add a placeholder for the AI response
        let loadingMessage = Message(content: "", isUser: false, isProcessing: true)
        chat.messages.append(loadingMessage)
        
        updateChat(chat)
        
        // Get AI response
        isProcessingResponse = true
        
        Task {
            do {
                let response = try await modelHandler.generateResponse(
                    messages: chat.messages.dropLast(),
                    modelType: selectedModelType
                )
                
                await MainActor.run {
                    self.isProcessingResponse = false
                    
                    // Update with actual response
                    guard var updatedChat = self.currentChat else { return }
                    if updatedChat.messages.count >= 2 {
                        updatedChat.messages[updatedChat.messages.count - 1] = Message(
                            content: response,
                            isUser: false
                        )
                        updatedChat.updatedAt = Date()
                        
                        // Update title if this is the first exchange
                        if updatedChat.messages.count == 2 {
                            Task {
                                let title = try await self.modelHandler.generateTitle(from: content)
                                await MainActor.run {
                                    updatedChat.title = title
                                    self.updateChat(updatedChat)
                                }
                            }
                        } else {
                            self.updateChat(updatedChat)
                        }
                    }
                }
            } catch {
                await MainActor.run {
                    self.isProcessingResponse = false
                    
                    // Update with error message
                    guard var updatedChat = self.currentChat else { return }
                    if updatedChat.messages.count >= 2 {
                        updatedChat.messages[updatedChat.messages.count - 1] = Message(
                            content: "Sorry, I wasn't able to respond. Please try again.",
                            isUser: false
                        )
                        self.updateChat(updatedChat)
                    }
                }
            }
        }
    }
}