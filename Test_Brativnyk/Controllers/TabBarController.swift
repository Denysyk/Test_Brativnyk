//
//  TabBarController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {
    
    private var customTabBar: CustomTabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupCustomTabBar()
        setupViewControllers()
    }
    
    // MARK: - Setup Methods
    
    private func setupCustomTabBar() {
        // Hide standard TabBar
        self.tabBar.isHidden = true
        
        // Create custom TabBar
        customTabBar = CustomTabBar()
        customTabBar.delegate = self
        
        view.addSubview(customTabBar)
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            customTabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            customTabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            customTabBar.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    private func setupViewControllers() {
        let chatVC = createViewController(
            ChatViewController(),
            title: NSLocalizedString("Chat", comment: "")
        )
        
        let ipInfoVC = createViewController(
            IPInfoViewController(),
            title: NSLocalizedString("IP Info", comment: "")
        )
        
        let historyVC = createViewController(
            HistoryViewController(),
            title: NSLocalizedString("History", comment: "")
        )
        
        let settingsVC = createViewController(
            SettingsViewController(),
            title: NSLocalizedString("Settings", comment: "")
        )
        
        viewControllers = [chatVC, ipInfoVC, historyVC, settingsVC]
        selectedIndex = 0
    }
    
    private func createViewController(_ viewController: UIViewController, title: String) -> UINavigationController {
        let navController = UINavigationController(rootViewController: viewController)
        
        navController.navigationBar.prefersLargeTitles = false
        
        viewController.navigationItem.title = title
        
        navController.navigationBar.isTranslucent = true
        
        return navController
    }
    
    // MARK: - Public Methods for Keyboard Handling
    
    func hideCustomTabBar() {
        UIView.animate(withDuration: 0.3) {
            self.customTabBar.alpha = 0
            self.customTabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    func showCustomTabBar() {
        UIView.animate(withDuration: 0.3) {
            self.customTabBar.alpha = 1
            self.customTabBar.transform = .identity
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard selectedViewController != viewController else {
            return false
        }

        if let currentVC = selectedViewController {
            currentVC.view.endEditing(true)
        }

        return true
    }
}

// MARK: - CustomTabBarDelegate
extension TabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        // Check if we're not trying to select already selected tab
        if self.selectedIndex == index {
            return
        }

        if let currentVC = self.selectedViewController {
            currentVC.view.endEditing(true)
        }
        
        self.selectedIndex = index
    }
}

// MARK: - Public Methods for Programmatic Tab Selection
extension TabBarController {
    override var selectedIndex: Int {
        didSet {
            // When selectedIndex changes programmatically, update custom tab bar
            if selectedIndex != oldValue {
                customTabBar.selectButton(at: selectedIndex)
            }
        }
    }
}
