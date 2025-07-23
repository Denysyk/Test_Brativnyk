//
//  ChatService.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import Foundation

class ChatService {
    static let shared = ChatService()
    
    private init() {}
    
    private let botResponseKeys = [
        "bot_response_1", "bot_response_2", "bot_response_3", "bot_response_4", "bot_response_5",
        "bot_response_6", "bot_response_7", "bot_response_8", "bot_response_9", "bot_response_10",
        "bot_response_11", "bot_response_12", "bot_response_13", "bot_response_14", "bot_response_15"
    ]
    
    // MARK: - Public Methods
    
    func getBotResponse() -> String {
        let randomIndex = Int.random(in: 0..<botResponseKeys.count)
        let key = botResponseKeys[randomIndex]
        return NSLocalizedString(key, comment: "")
    }
    
    func generateBotResponseWithDelay(completion: @escaping (String) -> Void) {
        // Simulate bot response delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0.5...2.0)) {
            completion(self.getBotResponse())
        }
    }
}
