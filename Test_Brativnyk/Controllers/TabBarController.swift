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
        
        // Вимикаємо великі заголовки
        navController.navigationBar.prefersLargeTitles = false
        
        // Встановлюємо звичайний заголовок
        viewController.navigationItem.title = title
        
        // Додаткові налаштування навігаційного бара (опціонально)
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
        // Forcefully end editing in current view controller
        if let nav = selectedViewController as? UINavigationController {
            nav.topViewController?.view.endEditing(true)
            if let chatVC = nav.topViewController as? ChatViewController {
                chatVC.cleanupInputSessions()
            }
        }
        
        // Add small delay to allow input system to clean up
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) ?? 0
        }
        
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        // FIXED: Очистка після переключення - без затримки
        view.endEditing(true)
    }
}

// MARK: - CustomTabBarDelegate
extension TabBarController: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        // FIXED: Більш агресивна очистка input sessions згідно з форумами
        if let currentVC = selectedViewController as? UINavigationController,
           let chatVC = currentVC.topViewController as? ChatViewController {
            // Специфічно для ChatViewController - прибираємо firstResponder
            chatVC.view.endEditing(true)
        }
        
        // Загальна очистка для всіх view controllers
        view.endEditing(true)
        
        // Встановлюємо новий індекс без затримки
        selectedIndex = index
    }
}

// MARK: - Public Methods for Programmatic Tab Selection
extension TabBarController {
    override var selectedIndex: Int {
        didSet {
            // Коли selectedIndex змінюється програмно, оновлюємо кастомний таб бар
            if selectedIndex != oldValue {
                customTabBar.selectButton(at: selectedIndex)
            }
        }
    }
}
