//
//  HistoryNavigationManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class HistoryNavigationManager {
    weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func navigateToChat(with session: ChatSession) {
        guard let chatId = session.id,
              let tabBarController = viewController?.tabBarController as? TabBarController else { return }
        
        tabBarController.selectedIndex = TabBarItem.chatIndex
        
        if let navController = tabBarController.viewControllers?[TabBarItem.chatIndex] as? UINavigationController,
           let chatViewController = navController.topViewController as? ChatViewController {
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                chatViewController.loadChatWithId(chatId)
            }
        }
    }
    
    func showClearAllConfirmation(onConfirm: @escaping () -> Void) {
        let alert = UIAlertController(
            title: NSLocalizedString("Clear All History", comment: ""),
            message: NSLocalizedString("This will permanently delete all your chat conversations. This action cannot be undone.", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear All", comment: ""), style: .destructive) { _ in
            onConfirm()
        })
        
        viewController?.present(alert, animated: true)
    }
}
