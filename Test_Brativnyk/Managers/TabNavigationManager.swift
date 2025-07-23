//
//  TabNavigationManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class TabNavigationManager {
    weak var tabBarController: UITabBarController?
    private let customTabBarManager: CustomTabBarManager
    
    init(tabBarController: UITabBarController, customTabBarManager: CustomTabBarManager) {
        self.tabBarController = tabBarController
        self.customTabBarManager = customTabBarManager
    }
    
    func selectTab(at index: Int) -> Bool {
        guard let tabBarController = tabBarController,
              index != tabBarController.selectedIndex,
              index < tabBarController.viewControllers?.count ?? 0 else {
            return false
        }
        
        dismissKeyboardFromCurrentViewController()
        
        tabBarController.selectedIndex = index
        customTabBarManager.selectTab(at: index)
        
        return true
    }
    
    func shouldSelectTab(at index: Int) -> Bool {
        guard let tabBarController = tabBarController else { return false }
        return tabBarController.selectedIndex != index
    }
    
    private func dismissKeyboardFromCurrentViewController() {
        tabBarController?.selectedViewController?.view.endEditing(true)
    }
    
    func getCurrentSelectedIndex() -> Int {
        return tabBarController?.selectedIndex ?? 0
    }
    
    func getViewController(at index: Int) -> UIViewController? {
        guard let viewControllers = tabBarController?.viewControllers,
              index < viewControllers.count else {
            return nil
        }
        return viewControllers[index]
    }
}
