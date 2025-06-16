import SwiftUI

struct ChatView: View {
    let chat: Chat
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(chat.messages) { message in
                        MessageBubble(message: message)
                    }
                }
                .padding()
                .id("MessagesEnd")
            }
            .onChange(of: chat.messages.count) { _ in
                withAnimation {
                    scrollProxy.scrollTo("MessagesEnd", anchor: .bottom)
                }
            }
            .background(themeManager.background)
        }
    }
}

struct MessageBubble: View {
    let message: Message
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            if message.isUser {
                Spacer()
            }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 4) {
                if message.isProcessing {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { i in
                            Circle()
                                .fill(themeManager.textSecondary)
                                .frame(width: 6, height: 6)
                                .opacity(0.5)
                                .scaleEffect(animationValue(for: i))
                                .animation(
                                    Animation.easeInOut(duration: 0.5)
                                        .repeatForever()
                                        .delay(0.2 * Double(i)),
                                    value: animationValue(for: i)
                                )
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 12)
                } else {
                    Text(message.content)
                        .font(themeManager.bodyFont)
                        .foregroundColor(message.isUser ? .white : themeManager.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
            .background(
                message.isUser ? themeManager.userMessageBackground : themeManager.aiMessageBackground
            )
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.75, alignment: message.isUser ? .trailing : .leading)
            
            if !message.isUser {
                Spacer()
            }
        }
    }
    
    private func animationValue(for index: Int) -> CGFloat {
        return 1.0 + (0.1 * (CGFloat(index) / 3))
    }
}

struct ChatInputView: View {
    @State private var messageText = ""
    @State private var isThinking = false
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Model selector
            ModelSelectorView()
                .padding(.vertical, 8)
            
            // Input field
            HStack(spacing: 12) {
                TextField("Message...", text: $messageText, axis: .vertical)
                    .focused($isTextFieldFocused)
                    .padding(12)
                    .background(themeManager.surfaceBackground)
                    .cornerRadius(24)
                    .font(themeManager.bodyFont)
                    .foregroundColor(themeManager.textPrimary)
                    .lineLimit(5)
                    .disabled(chatStore.isProcessingResponse)
                
                Button(action: sendMessage) {
                    Image(systemName: chatStore.isProcessingResponse ? "stop.circle.fill" : "arrow.up.circle.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(
                            messageText.isEmpty && !chatStore.isProcessingResponse 
                                ? themeManager.textSecondary 
                                : themeManager.primary
                        )
                }
                .disabled(messageText.isEmpty && !chatStore.isProcessingResponse)
                .animation(.easeInOut, value: chatStore.isProcessingResponse)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(themeManager.background)
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(themeManager.surfaceBackground),
                alignment: .top
            )
        }
    }
    
    private func sendMessage() {
        if chatStore.isProcessingResponse {
            // TODO: Implement cancellation
            return
        }
        
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let text = messageText
        messageText = ""
        chatStore.sendMessage(text)
    }
}

struct ModelSelectorView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(AIModelType.allCases) { modelType in
                    VStack(spacing: 3) {
                        Text(modelType.rawValue)
                            .font(themeManager.captionFont.weight(.medium))
                            .foregroundColor(
                                chatStore.selectedModelType == modelType 
                                    ? themeManager.primary 
                                    : themeManager.textSecondary
                            )
                            
                        if chatStore.selectedModelType == modelType {
                            Circle()
                                .fill(themeManager.primary)
                                .frame(width: 4, height: 4)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .onTapGesture {
                        withAnimation {
                            chatStore.selectedModelType = modelType
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}