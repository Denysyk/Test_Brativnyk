//
//  ChatMessage.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

enum MessageType {
    case user
    case bot
}

struct ChatMessage {
    let id: UUID
    let text: String
    let type: MessageType
    let timestamp: Date
    
    init(text: String, type: MessageType) {
        guard !text.isEmpty else {
            fatalError("ChatMessage text cannot be empty")
        }
        
        self.id = UUID()
        self.text = text
        self.type = type
        
        let now = Date()
        if now.timeIntervalSince1970.isFinite &&
           !now.timeIntervalSince1970.isNaN &&
           !now.timeIntervalSince1970.isInfinite {
            self.timestamp = now
        } else {
            self.timestamp = Date(timeIntervalSince1970: 0)
        }
    }
    
    init(id: UUID, text: String, type: MessageType, timestamp: Date) {
        guard !text.isEmpty else {
            fatalError("ChatMessage text cannot be empty")
        }
        
        guard id.uuidString.count > 0 else {
            fatalError("ChatMessage id cannot be empty")
        }
        
        guard timestamp.timeIntervalSince1970.isFinite &&
              !timestamp.timeIntervalSince1970.isNaN &&
              !timestamp.timeIntervalSince1970.isInfinite else {
            fatalError("ChatMessage timestamp must be valid")
        }
        
        self.id = id
        self.text = text
        self.type = type
        self.timestamp = timestamp
    }
    
 
    var isValid: Bool {
        return !text.isEmpty &&
               !id.uuidString.isEmpty &&
               timestamp.timeIntervalSince1970.isFinite &&
               !timestamp.timeIntervalSince1970.isNaN &&
               !timestamp.timeIntervalSince1970.isInfinite
    }
    
    // MARK: - Computed Properties
    var formattedTimestamp: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    var displayText: String {
        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
