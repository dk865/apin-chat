import Foundation
import FoundationModels
import OSLog

// This class handles interactions with Apple's Foundation Models framework
class AIModelHandler {
    private let logger = Logger(subsystem: "com.dk865.ApinChat", category: "AIModelHandler")
    
    // Generate a response from the AI model
    func generateResponse(messages: [Message], modelType: AIModelType) async throws -> String {
        logger.info("Generating response using \(modelType.rawValue) model")
        
        // Create the conversation history
        var conversation: [Message] = []
        
        // Add system prompt based on model type
        let systemMessage = Message(
            content: modelType.systemPrompt,
            isUser: false
        )
        
        conversation.append(systemMessage)
        conversation.append(contentsOf: messages)
        
        do {
            // Create the model request
            let model = try await ConversationalModel(modelMode: convertToModelMode(modelType))
            
            // Convert our messages to the format expected by the Apple Intelligence API
            let conversationTurns = conversation.map { message -> ModelTurn in
                let role: ModelTurn.Role = message.isUser ? .user : .assistant
                return ModelTurn(role: role, content: message.content)
            }
            
            // Generate the response
            logger.info("Sending request to model with \(conversationTurns.count) turns")
            let response = try await model.generateResponse(for: conversationTurns)
            
            logger.info("Received response from model")
            return response.content
        } catch {
            logger.error("Error generating response: \(error.localizedDescription)")
            throw error
        }
    }
    
    // Generate a title for a new chat based on the first message
    func generateTitle(from firstMessage: String) async throws -> String {
        logger.info("Generating title for chat")
        
        do {
            // Create title-specific model
            let model = try await ConversationalModel(modelMode: .precise) 
            
            let conversation: [ModelTurn] = [
                ModelTurn(role: .assistant, content: "Create a very short title (3-5 words) for a conversation that starts with this message. Return only the title without quotes or additional text."),
                ModelTurn(role: .user, content: firstMessage)
            ]
            
            let response = try await model.generateResponse(for: conversation)
            
            // Format the title
            let title = response.content.trimmingCharacters(in: .whitespacesAndNewlines)
                .replacingOccurrences(of: "\"", with: "")
            
            // If the title is too long, truncate it
            if title.count > 30 {
                return String(title.prefix(27)) + "..."
            }
            
            return title.isEmpty ? "New Chat" : title
        } catch {
            logger.error("Error generating title: \(error.localizedDescription)")
            return "New Chat"
        }
    }
    
    // Convert our app's model types to Foundation Models framework types
    private func convertToModelMode(_ modelType: AIModelType) -> ConversationalModel.ModelMode {
        switch modelType {
        case .conversation:
            return .conversational
        case .creative:
            return .creative
        case .precise:
            return .precise
        }
    }
}