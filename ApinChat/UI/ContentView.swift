import SwiftUI
import FoundationModels

struct ContentView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingSidebar: Bool = false
    @State private var showingSettings: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background.ignoresSafeArea()
                
                // Show appropriate view based on model availability
                switch chatStore.modelAvailability {
                case .available:
                    availableModelView
                case .unavailable(.deviceNotEligible):
                    ModelUnavailableView(
                        title: "Device Not Supported",
                        message: "This device doesn't support Apple Intelligence. Please use a compatible device.",
                        systemImage: "exclamationmark.triangle"
                    )
                case .unavailable(.appleIntelligenceNotEnabled):
                    ModelUnavailableView(
                        title: "Apple Intelligence Disabled",
                        message: "Please enable Apple Intelligence in System Settings to use Apin Chat.",
                        systemImage: "gear",
                        actionTitle: "Open Settings",
                        action: openSystemSettings
                    )
                case .unavailable(.modelNotReady):
                    ModelUnavailableView(
                        title: "Model Downloading",
                        message: "The AI model is still downloading. This may take a few minutes.",
                        systemImage: "arrow.down.circle",
                        actionTitle: "Check Again",
                        action: chatStore.checkModelAvailability
                    )
                case .unavailable(let other):
                    ModelUnavailableView(
                        title: "Model Unavailable",
                        message: "The AI model is currently unavailable: \(other). This may be due to low battery or the device being too warm.",
                        systemImage: "exclamationmark.circle",
                        actionTitle: "Retry",
                        action: chatStore.checkModelAvailability
                    )
                }
                
                // Sidebar overlay when visible
                if showingSidebar && chatStore.modelAvailability == .available {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                        .onTapGesture {
                            withAnimation {
                                showingSidebar = false
                            }
                        }
                }
            }
            .overlay(
                SidebarView(isShowing: $showingSidebar)
                    .offset(x: showingSidebar ? 0 : -300, y: 0)
                    .animation(.easeInOut, value: showingSidebar),
                alignment: .leading
            )
            .navigationTitle("Apin Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            showingSidebar.toggle()
                        }
                    }) {
                        Image(systemName: "sidebar.left")
                            .foregroundColor(themeManager.primary)
                    }
                    .disabled(chatStore.modelAvailability != .available)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingSettings.toggle()
                    }) {
                        Image(systemName: "gear")
                            .foregroundColor(themeManager.primary)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("AI Model Unavailable", isPresented: $chatStore.showingModelUnavailableAlert) {
                Button("OK") { }
                Button("Check Again") {
                    chatStore.checkModelAvailability()
                }
            } message: {
                Text(modelUnavailableMessage)
            }
            .onAppear {
                chatStore.checkModelAvailability()
            }
        }
    }
    
    @ViewBuilder
    private var availableModelView: some View {
        if chatStore.chats.isEmpty {
            EmptyStateView()
        } else if let currentChat = chatStore.currentChat {
            VStack(spacing: 0) {
                // Chat messages
                ChatView(chat: currentChat)
                
                // Model selector and input
                ChatInputView()
            }
        } else {
            // Fallback if no chat is selected
            StartChatView()
        }
    }
    
    private var modelUnavailableMessage: String {
        switch chatStore.modelAvailability {
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
    }
    
    private func openSystemSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

struct ModelUnavailableView: View {
    let title: String
    let message: String
    let systemImage: String
    var actionTitle: String?
    var action: (() -> Void)?
    
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(themeManager.primary)
            
            VStack(spacing: 12) {
                Text(title)
                    .font(themeManager.titleFont)
                    .foregroundColor(themeManager.textPrimary)
                
                Text(message)
                    .font(themeManager.bodyFont)
                    .foregroundColor(themeManager.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .font(themeManager.bodyFont)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(themeManager.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .padding(.top, 8)
            }
            
            Spacer()
        }
        .padding()
    }
}

struct EmptyStateView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(themeManager.primary)
            
            Text("Welcome to Apin")
                .font(themeManager.titleFont)
                .foregroundColor(themeManager.textPrimary)
            
            Text("Start a new conversation to begin chatting")
                .font(themeManager.bodyFont)
                .foregroundColor(themeManager.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                chatStore.createNewChat()
            }) {
                Label("New Chat", systemImage: "plus.bubble")
                    .frame(width: 200)
            }
            .primaryButton(theme: themeManager)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.background)
    }
}

struct StartChatView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "bubble.left.and.bubble.right.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(themeManager.primary)
            
            Text("No Chat Selected")
                .font(themeManager.titleFont)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Button(action: {
                chatStore.createNewChat()
            }) {
                Label("New Chat", systemImage: "plus.bubble")
                    .frame(width: 200)
            }
            .primaryButton(theme: themeManager)
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(themeManager.background)
    }
}