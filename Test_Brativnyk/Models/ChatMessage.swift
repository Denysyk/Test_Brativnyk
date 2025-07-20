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
        self.id = UUID()
        self.text = text
        self.type = type
        self.timestamp = Date()
    }
    
    init(id: UUID, text: String, type: MessageType, timestamp: Date) {
        self.id = id
        self.text = text
        self.type = type
        self.timestamp = timestamp
    }
}
