import SwiftUI

struct SidebarView: View {
    @Binding var isShowing: Bool
    @EnvironmentObject private var chatStore: ChatStore
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var showingDeleteConfirmation = false
    @State private var chatToDelete: Chat? = nil
    
    var body: some View {
        ZStack {
            themeManager.elevatedBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // Header
                HStack {
                    Text("Apin Chat")
                        .font(themeManager.titleFont)
                        .foregroundColor(themeManager.primary)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(themeManager.textSecondary)
                            .padding(8)
                            .background(Circle().fill(themeManager.surfaceBackground))
                    }
                }
                .padding()
                
                // New Chat button
                Button(action: {
                    chatStore.createNewChat()
                    withAnimation {
                        isShowing = false
                    }
                }) {
                    Label("New Chat", systemImage: "plus")
                        .frame(maxWidth: .infinity)
                }
                .primaryButton(theme: themeManager)
                .padding(.horizontal)
                .padding(.bottom)
                
                Divider()
                    .background(themeManager.surfaceBackground)
                
                // Chats list
                ScrollView {
                    VStack(alignment: .leading, spacing: 2) {
                        ForEach(chatStore.chats) { chat in
                            ChatRowView(chat: chat, isSelected: chatStore.currentChat?.id == chat.id)
                                .onTapGesture {
                                    chatStore.selectChat(chat)
                                    withAnimation {
                                        isShowing = false
                                    }
                                }
                                .contextMenu {
                                    Button(action: {
                                        chatToDelete = chat
                                        showingDeleteConfirmation = true
                                    }) {
                                        Label("Delete", systemImage: "trash")
                                    }
                                    
                                    Button(action: {
                                        // TODO: Share chat functionality
                                    }) {
                                        Label("Share", systemImage: "square.and.arrow.up")
                                    }
                                }
                        }
                    }
                    .padding(.vertical)
                }
                
                Spacer()
                
                // Footer with creator info
                VStack(alignment: .center, spacing: 2) {
                    Text("Created by")
                        .font(themeManager.captionFont)
                        .foregroundColor(themeManager.textSecondary)
                    
                    Text("dk865")
                        .font(themeManager.captionFont.weight(.bold))
                        .foregroundColor(themeManager.primary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 10)
            }
            .frame(width: 300)
            .background(themeManager.elevatedBackground)
            .alert("Delete Chat", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let chat = chatToDelete {
                        chatStore.deleteChat(chat)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this chat? This action cannot be undone.")
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    let isSelected: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(chat.title)
                    .font(themeManager.headlineFont)
                    .foregroundColor(
                        isSelected ? themeManager.primary : themeManager.textPrimary
                    )
                    .lineLimit(1)
                
                Text(chat.lastMessage)
                    .font(themeManager.captionFont)
                    .foregroundColor(themeManager.textSecondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            if isSelected {
                Circle()
                    .fill(themeManager.primary)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            isSelected ? 
                themeManager.surfaceBackground.opacity(0.5) : 
                Color.clear
        )
    }
}