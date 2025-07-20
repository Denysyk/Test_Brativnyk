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
    
    static let allItems: [TabBarItem] = [
        TabBarItem(icon: "message", selectedIcon: "message.fill", title: "Chat"),
        TabBarItem(icon: "paperplane", selectedIcon: "paperplane.fill", title: "IP Info"),
        TabBarItem(icon: "clock", selectedIcon: "clock.fill", title: "History"),
        TabBarItem(icon: "gearshape", selectedIcon: "gearshape.fill", title: "Settings")
    ]
}
