import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var chatStore: ChatStore
    @Environment(\.dismiss) private var dismiss
    @State private var showingClearConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                themeManager.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // App info section
                        VStack(alignment: .center, spacing: 16) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                                .foregroundColor(themeManager.primary)
                            
                            Text("Apin Chat")
                                .font(themeManager.titleFont)
                                .foregroundColor(themeManager.textPrimary)
                            
                            Text("Version 1.0.0")
                                .font(themeManager.captionFont)
                                .foregroundColor(themeManager.textSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        
                        // Model settings
                        Section(header: SectionHeaderView(title: "Model Settings")) {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(AIModelType.allCases) { modelType in
                                    HStack(spacing: 14) {
                                        Circle()
                                            .fill(modelType == chatStore.selectedModelType ? 
                                                  themeManager.primary : themeManager.textSecondary)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Image(systemName: "checkmark")
                                                    .font(.system(size: 10, weight: .bold))
                                                    .foregroundColor(.white)
                                                    .opacity(modelType == chatStore.selectedModelType ? 1 : 0)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(modelType.rawValue)
                                                .font(themeManager.headlineFont)
                                                .foregroundColor(themeManager.textPrimary)
                                            
                                            Text(modelType.description)
                                                .font(themeManager.captionFont)
                                                .foregroundColor(themeManager.textSecondary)
                                        }
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        withAnimation {
                                            chatStore.selectedModelType = modelType
                                        }
                                    }
                                    .padding(.vertical, 6)
                                }
                            }
                            .padding()
                            .background(themeManager.surfaceBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // Chat management
                        Section(header: SectionHeaderView(title: "Chat Management")) {
                            Button(action: {
                                showingClearConfirmation = true
                            }) {
                                HStack {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    
                                    Text("Clear All Chats")
                                        .foregroundColor(.red)
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(themeManager.textSecondary)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                            }
                            .padding()
                            .background(themeManager.surfaceBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                        
                        // About section
                        Section(header: SectionHeaderView(title: "About")) {
                            VStack(alignment: .leading, spacing: 16) {
                                InfoRow(icon: "person.fill", title: "Developer", value: "dk865")
                                
                                Divider()
                                    .background(themeManager.surfaceBackground)
                                
                                InfoRow(icon: "apple.logo", title: "Requires", value: "iOS 26.0+")
                                
                                Divider()
                                    .background(themeManager.surfaceBackground)
                                
                                InfoRow(icon: "brain.head.profile", title: "Powered by", value: "Foundation Models")
                                
                                Divider()
                                    .background(themeManager.surfaceBackground)
                                
                                Link(destination: URL(string: "https://github.com/dk865/apin-chat")!) {
                                    InfoRow(icon: "link", title: "GitHub Repository", value: "")
                                }
                            }
                            .padding()
                            .background(themeManager.surfaceBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(themeManager.primary)
                }
            }
            .alert("Clear All Chats", isPresented: $showingClearConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Clear All", role: .destructive) {
                    chatStore.clearAllChats()
                }
            } message: {
                Text("Are you sure you want to delete all chats? This action cannot be undone.")
            }
        }
    }
}

struct SectionHeaderView: View {
    let title: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        Text(title)
            .font(themeManager.headlineFont)
            .foregroundColor(themeManager.primary)
            .padding(.horizontal)
            .padding(.bottom, 4)
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(themeManager.primary)
                .frame(width: 24)
            
            Text(title)
                .font(themeManager.bodyFont)
                .foregroundColor(themeManager.textPrimary)
            
            Spacer()
            
            Text(value)
                .font(themeManager.bodyFont)
                .foregroundColor(themeManager.textSecondary)
        }
    }
}