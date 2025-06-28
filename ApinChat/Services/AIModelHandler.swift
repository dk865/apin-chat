import Foundation
import FoundationModels
import OSLog

// This class handles interactions with Apple's Foundation Models framework
class AIModelHandler {
    private let logger = Logger(subsystem: "com.dk865.ApinChat", category: "AIModelHandler")
    private let model = SystemLanguageModel.default
    
    // Check if the Foundation Model is available
    var isModelAvailable: Bool {
        model.availability == .available
    }
    
    // Get the current model availability status
    var modelAvailability: SystemLanguageModel.Availability {
        model.availability
    }
    
    // Generate a response from the AI model
    func generateResponse(messages: [Message], modelType: AIModelType) async throws -> String {
        logger.info("Generating response using \(modelType.rawValue) model")
        
        // Check model availability first
        guard model.availability == .available else {
            throw ModelError.modelUnavailable(model.availability)
        }
        
        do {
            // Create session with instructions based on model type
            let instructions = modelType.instructions
            let session = LanguageModelSession(instructions: instructions)
            
            // Create the prompt from conversation history
            let prompt = buildPrompt(from: messages)
            
            // Configure generation options based on model type
            let options = GenerationOptions(temperature: modelType.temperature)
            
            logger.info("Sending request to model")
            let response = try await session.respond(to: prompt, options: options)
            
            logger.info("Received response from model")
            return response
        } catch {
            logger.error("Error generating response: \(error.localizedDescription)")
            throw error
        }
    }
    
    
    // Generate a title for a new chat based on the first message
    func generateTitle(from firstMessage: String) async throws -> String {
        logger.info("Generating title for chat")
        
        // Check model availability first
        guard model.availability == .available else {
            return "New Chat"
        }
        
        do {
            // Create session with specific instructions for title generation
            let instructions = """
                Generate a concise title for a conversation based on the user's first message. 
                Keep the title between 3-7 words. 
                Return only the title without quotes or additional text.
                """
            
            let session = LanguageModelSession(instructions: instructions)
            
            let prompt = "Create a title for a conversation that starts with: \(firstMessage)"
            
            // Use lower temperature for more consistent title generation
            let options = GenerationOptions(temperature: 0.3)
            
            let response = try await session.respond(to: prompt, options: options)
            
            // Clean and format the title
            let title = response.trimmingCharacters(in: .whitespacesAndNewlines)
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
    
    // Build a prompt from the conversation history
    private func buildPrompt(from messages: [Message]) -> String {
        // Take only the user messages for context, excluding processing messages
        let userMessages = messages.filter { $0.isUser && !$0.isProcessing }
        
        if userMessages.isEmpty {
            return "Hello"
        }
        
        // For single-turn interactions, just return the last user message
        if userMessages.count == 1 {
            return userMessages.last?.content ?? "Hello"
        }
        
        // For multi-turn, include recent context (last 3-4 exchanges)
        let recentMessages = Array(messages.suffix(6)) // Last 6 messages for context
        let context = recentMessages.map { message in
            let role = message.isUser ? "User" : "Assistant"
            return "\(role): \(message.content)"
        }.joined(separator: "\n")
        
        return context
    }
}

// Error types for model handling
enum ModelError: Error, LocalizedError {
    case modelUnavailable(SystemLanguageModel.Availability)
    case sessionBusy
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .modelUnavailable(let availability):
            switch availability {
            case .unavailable(.deviceNotEligible):
                return "This device doesn't support Apple Intelligence."
            case .unavailable(.appleIntelligenceNotEnabled):
                return "Please enable Apple Intelligence in System Settings."
            case .unavailable(.modelNotReady):
                return "The AI model is still downloading. Please try again later."
            case .unavailable(let other):
                return "The AI model is currently unavailable: \(other)"
            default:
                return "The AI model is currently unavailable."
            }
        case .sessionBusy:
            return "The AI model is currently processing another request."
        case .invalidResponse:
            return "Received an invalid response from the AI model."
        }
    }
}