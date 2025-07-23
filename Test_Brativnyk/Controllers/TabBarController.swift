//
//  TabBarController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate, CustomTabBarManagerDelegate {
    
    // MARK: - Managers
    private var customTabBarManager: CustomTabBarManager!
    private var navigationManager: TabNavigationManager!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
        setupManagers()
        setupViewControllers()
    }
    
    // MARK: - Setup Methods
    private func setupTabBarController() {
        delegate = self
        tabBar.isHidden = true
    }
    
    private func setupManagers() {
        customTabBarManager = CustomTabBarManager(parentView: view)
        customTabBarManager.delegate = self
        
        navigationManager = TabNavigationManager(
            tabBarController: self,
            customTabBarManager: customTabBarManager
        )
    }
    
    private func setupViewControllers() {
        viewControllers = TabBarFactory.createTabBarControllers()
        selectedIndex = TabBarItem.chatIndex
    }
    
    // MARK: - Public Methods
    func hideCustomTabBar() {
        customTabBarManager.hideTabBar()
    }
    
    func showCustomTabBar() {
        customTabBarManager.showTabBar()
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let index = viewControllers?.firstIndex(of: viewController) else { return false }
        return navigationManager.shouldSelectTab(at: index)
    }
    
    // MARK: - CustomTabBarManagerDelegate
    func didSelectTab(at index: Int) {
        let success = navigationManager.selectTab(at: index)
        if success {
            HapticFeedback.impact(.light)
        }
    }
    
    func shouldSelectTab(at index: Int) -> Bool {
        return navigationManager.shouldSelectTab(at: index)
    }
    
    // MARK: - Override selectedIndex for programmatic selection
    override var selectedIndex: Int {
        didSet {
            if selectedIndex != oldValue {
                customTabBarManager.selectTab(at: selectedIndex)
            }
        }
    }
}
