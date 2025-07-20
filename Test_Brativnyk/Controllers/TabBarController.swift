//
//  TabBarController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class TabBarController: UITabBarController {
    
    private var customTabBar: CustomTabBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
        setupViewControllers()
    }
    
    private func setupCustomTabBar() {
        // Ховаємо стандартний TabBar
        self.tabBar.isHidden = true
        
        // Створюємо кастомний TabBar
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
        navController.navigationBar.prefersLargeTitles = true
        viewController.navigationItem.title = title
        return navController
    }
}

// MARK: - CustomTabBarDelegate
extension TabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        selectedIndex = index
    }
}
