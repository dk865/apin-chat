import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingSidebar: Bool = false
    @State private var showingSettings: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background.ignoresSafeArea()
                
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
                
                // Sidebar overlay when visible
                if showingSidebar {
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
        }
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