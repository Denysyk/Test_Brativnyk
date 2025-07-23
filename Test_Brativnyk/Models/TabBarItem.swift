//
//  TabBarItem.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import Foundation

struct TabBarItem {
    let icon: String
    let selectedIcon: String
    let title: String
    
    // MARK: - Computed Properties
    var localizedTitle: String {
        return NSLocalizedString(title, comment: "")
    }
    
    // MARK: - Static Data
    static let allItems: [TabBarItem] = [
        TabBarItem(icon: "message", selectedIcon: "message.fill", title: "Chat"),
        TabBarItem(icon: "paperplane", selectedIcon: "paperplane.fill", title: "IP Info"),
        TabBarItem(icon: "clock", selectedIcon: "clock.fill", title: "History"),
        TabBarItem(icon: "gearshape", selectedIcon: "gearshape.fill", title: "Settings")
    ]
    
    // MARK: - Validation
    var isValid: Bool {
        return !icon.isEmpty && !selectedIcon.isEmpty && !title.isEmpty
    }
}

// MARK: - Extensions for better organization
extension TabBarItem {
    
    static let chatIndex = 0
    static let ipInfoIndex = 1
    static let historyIndex = 2
    static let settingsIndex = 3
    
    // Helper methods
    static func item(at index: Int) -> TabBarItem? {
        guard index >= 0 && index < allItems.count else { return nil }
        return allItems[index]
    }
}
