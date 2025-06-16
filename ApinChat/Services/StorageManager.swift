import Foundation

class StorageManager {
    private let chatsKey = "stored_chats"
    private let logger = Logger(subsystem: "com.dk865.ApinChat", category: "StorageManager")
    
    func saveChats(_ chats: [Chat]) {
        do {
            let data = try JSONEncoder().encode(chats)
            UserDefaults.standard.set(data, forKey: chatsKey)
            logger.info("Saved \(chats.count) chats")
        } catch {
            logger.error("Failed to save chats: \(error.localizedDescription)")
        }
    }
    
    func loadChats() -> [Chat] {
        guard let data = UserDefaults.standard.data(forKey: chatsKey) else {
            logger.info("No saved chats found")
            return []
        }
        
        do {
            let chats = try JSONDecoder().decode([Chat].self, from: data)
            logger.info("Loaded \(chats.count) chats")
            return chats
        } catch {
            logger.error("Failed to load chats: \(error.localizedDescription)")
            return []
        }
    }
    
    func clearAllChats() {
        UserDefaults.standard.removeObject(forKey: chatsKey)
        logger.info("Cleared all chats")
    }
}