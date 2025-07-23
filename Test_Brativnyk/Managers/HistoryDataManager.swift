//
//  HistoryDataManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

protocol HistoryDataManagerDelegate: AnyObject {
    func didUpdateChatSessions(_ sessions: [ChatSession])
    func didDeleteSession(at index: Int)
    func didClearAllSessions()
}

class HistoryDataManager {
    weak var delegate: HistoryDataManagerDelegate?
    private(set) var chatSessions: [ChatSession] = []
    
    init() {
        setupNotifications()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleChatSessionUpdated),
            name: NSNotification.Name("ChatSessionUpdated"),
            object: nil
        )
    }
    
    @objc private func handleChatSessionUpdated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadChatSessions()
        }
    }
    
    func loadChatSessions() {
        chatSessions = CoreDataManager.shared.getAllChatSessions()
        delegate?.didUpdateChatSessions(chatSessions)
    }
    
    func deleteSession(at index: Int) {
        guard index < chatSessions.count else { return }
        
        let sessionToDelete = chatSessions[index]
        CoreDataManager.shared.deleteChatSession(sessionToDelete)
        
        chatSessions.remove(at: index)
        delegate?.didDeleteSession(at: index)
    }
    
    func clearAllSessions() {
        CoreDataManager.shared.deleteAllData()
        chatSessions.removeAll()
        delegate?.didClearAllSessions()
    }
    
    func getSession(at index: Int) -> ChatSession? {
        guard index < chatSessions.count else { return nil }
        return chatSessions[index]
    }
    
    var isEmpty: Bool {
        return chatSessions.isEmpty
    }
    
    var count: Int {
        return chatSessions.count
    }
}
