//
//  ChatDataManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

class ChatDataManager {
    func getLastChatId() -> String? {
        return CoreDataManager.shared.getLastChatSession()?.id
    }
    
    func loadMessages(for chatId: String) -> [ChatMessage] {
        return CoreDataManager.shared.getChatMessages(chatId: chatId)
    }
    
    func saveMessage(_ message: ChatMessage, chatId: String) {
        CoreDataManager.shared.saveMessage(message, chatId: chatId)
    }
}
