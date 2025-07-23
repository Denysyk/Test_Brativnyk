//
//  SettingsDataManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation
import UIKit

struct SettingsItem {
    let title: String
    let icon: String
    let action: SettingsAction
    let accessoryType: UITableViewCell.AccessoryType
    let textColor: UIColor
    
    init(title: String, icon: String, action: SettingsAction, textColor: UIColor = UIColor.label) {
        self.title = title
        self.icon = icon
        self.action = action
        self.accessoryType = .disclosureIndicator
        self.textColor = textColor
    }
}

enum SettingsAction {
    case rateApp
    case shareApp
    case contactUs
}

class SettingsDataManager {
    
    private(set) var settingsItems: [SettingsItem] = []
    
    init() {
        setupSettingsItems()
    }
    
    private func setupSettingsItems() {
        settingsItems = [
            SettingsItem(
                title: NSLocalizedString("Rate App", comment: ""),
                icon: "star.fill",
                action: .rateApp
            ),
            SettingsItem(
                title: NSLocalizedString("Share App", comment: ""),
                icon: "square.and.arrow.up",
                action: .shareApp
            ),
            SettingsItem(
                title: NSLocalizedString("Contact Us", comment: ""),
                icon: "envelope.fill",
                action: .contactUs
            )
        ]
    }
    
    func getItem(at index: Int) -> SettingsItem? {
        guard index < settingsItems.count else { return nil }
        return settingsItems[index]
    }
    
    var count: Int {
        return settingsItems.count
    }
    
    var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}
