//
//  TabBarFactory.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class TabBarFactory {
    
    static func createTabBarControllers() -> [UINavigationController] {
        let chatVC = createChatViewController()
        let ipInfoVC = createIPInfoViewController()
        let historyVC = createHistoryViewController()
        let settingsVC = createSettingsViewController()
        
        return [chatVC, ipInfoVC, historyVC, settingsVC]
    }
    
    private static func createChatViewController() -> UINavigationController {
        let chatVC = ChatViewController()
        return createNavigationController(
            with: chatVC,
            title: LocalizationManager.TabBar.chat
        )
    }
    
    private static func createIPInfoViewController() -> UINavigationController {
        let ipInfoVC = IPInfoViewController()
        return createNavigationController(
            with: ipInfoVC,
            title: LocalizationManager.TabBar.ipInfo
        )
    }
    
    private static func createHistoryViewController() -> UINavigationController {
        let historyVC = HistoryViewController()
        return createNavigationController(
            with: historyVC,
            title: LocalizationManager.TabBar.history
        )
    }
    
    private static func createSettingsViewController() -> UINavigationController {
        let settingsVC = SettingsViewController()
        return createNavigationController(
            with: settingsVC,
            title: LocalizationManager.TabBar.settings
        )
    }
    
    private static func createNavigationController(with viewController: UIViewController, title: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.navigationBar.prefersLargeTitles = false
        navController.navigationBar.isTranslucent = true
        
        viewController.navigationItem.title = title
        
        return navController
    }
}
