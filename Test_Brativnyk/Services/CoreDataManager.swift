//
//  CoreDataManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation
import CoreData
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Test_Brativnyk")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data error: \(error)")
            }
        }
        return container
    }()
    
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Save context error: \(error)")
            }
        }
    }
    
    // MARK: - Chat Sessions
    
    func createChatSession(id: String) -> ChatSession {
        let chatSession = ChatSession(context: context)
        chatSession.id = id
        chatSession.title = NSLocalizedString("New Chat", comment: "")
        chatSession.createdAt = Date()
        chatSession.updatedAt = Date()
        
        saveContext()
        return chatSession
    }
    
    func getChatSession(id: String) -> ChatSession? {
        let request: NSFetchRequest<ChatSession> = ChatSession.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        request.fetchLimit = 1
        
        do {
            let sessions = try context.fetch(request)
            return sessions.first
        } catch {
            print("Error fetching chat session: \(error)")
            return nil
        }
    }
    
    func getOrCreateChatSession(id: String) -> ChatSession {
        if let existingSession = getChatSession(id: id) {
            return existingSession
        } else {
            return createChatSession(id: id)
        }
    }
    
    func getAllChatSessions() -> [ChatSession] {
        let request: NSFetchRequest<ChatSession> = ChatSession.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        
        do {
            return try context.fetch(request)
        } catch {
            print("Error fetching chat sessions: \(error)")
            return []
        }
    }
    
    func deleteChatSession(_ session: ChatSession) {
        context.delete(session)
        saveContext()
    }
    
    // MARK: - Messages
    
    func saveMessage(_ message: ChatMessage, chatId: String) {
        // Перевіряємо валідність даних перед збереженням
        guard !message.text.isEmpty,
              !message.id.uuidString.isEmpty,
              !message.timestamp.timeIntervalSince1970.isNaN,
              !chatId.isEmpty else {
            print("⚠️ Invalid message data, skipping save")
            return
        }
        
        let chatSession = getOrCreateChatSession(id: chatId)
        
        let messageEntity = Message(context: context)
        messageEntity.id = message.id.uuidString
        messageEntity.text = message.text
        messageEntity.isFromUser = (message.type == .user)
        messageEntity.timestamp = message.timestamp
        messageEntity.chatSession = chatSession
        
        // Оновлюємо chatSession
        chatSession.updatedAt = Date()
        
        // Якщо це перше повідомлення, встановлюємо його як title
        if chatSession.messages?.count == 0 || chatSession.title == NSLocalizedString("New Chat", comment: "") {
            let titleText = String(message.text.prefix(50))
            chatSession.title = titleText.isEmpty ? NSLocalizedString("New Chat", comment: "") : titleText
        }
        
        saveContext()
    }
    
    func getChatMessages(chatId: String) -> [ChatMessage] {
        guard !chatId.isEmpty,
              let chatSession = getChatSession(id: chatId) else {
            return []
        }
        
        let request: NSFetchRequest<Message> = Message.fetchRequest()
        request.predicate = NSPredicate(format: "chatSession == %@", chatSession)
        request.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: true)]
        
        do {
            let messageEntities = try context.fetch(request)
            return messageEntities.compactMap { entity in
                // Перевіряємо валідність даних перед створенням ChatMessage
                guard let id = entity.id, !id.isEmpty,
                      let text = entity.text, !text.isEmpty,
                      let timestamp = entity.timestamp,
                      !timestamp.timeIntervalSince1970.isNaN,
                      let uuid = UUID(uuidString: id) else {
                    print("⚠️ Invalid message entity, skipping")
                    return nil
                }
                
                return ChatMessage(
                    id: uuid,
                    text: text,
                    type: entity.isFromUser ? .user : .bot,
                    timestamp: timestamp
                )
            }
        } catch {
            print("Error fetching messages: \(error)")
            return []
        }
    }
    
    func deleteMessage(_ message: Message) {
        context.delete(message)
        saveContext()
    }
    
    // MARK: - Utility
    
    func deleteAllData() {
        let chatSessions = getAllChatSessions()
        for session in chatSessions {
            context.delete(session)
        }
        saveContext()
    }
}
