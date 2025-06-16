import SwiftUI

@main
struct ApinChatApp: App {
    @StateObject private var chatStore = ChatStore()
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(chatStore)
                .environmentObject(themeManager)
                .preferredColorScheme(.dark)
        }
    }
}