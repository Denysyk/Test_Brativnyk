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
        
        // Додаткові налаштування навігаційного бара
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
    // КРИТИЧНО ВАЖЛИВО: Цей метод закриває input sessions ДО переходу
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        // 1. Перевіряємо, чи ми не намагаємося вибрати вже вибрану вкладку
        guard selectedViewController != viewController else {
            return false
        }

        // 2. КРИТИЧНО ВАЖЛИВО: закриваємо input sessions ДО переходу
        if let currentVC = selectedViewController {
            currentVC.view.endEditing(true)
        }

        // 3. Дозволяємо перехід. Система сама обробить решту.
        return true
    }
}

// MARK: - CustomTabBarDelegate
extension TabBarController: CustomTabBarDelegate {
    // КРИТИЧНО: Закриваємо input sessions при переході через custom tab bar
    func didSelectTab(at index: Int) {
        // Перевіряємо, чи ми не намагаємося вибрати вже вибрану вкладку
        if self.selectedIndex == index {
            return
        }

        // КРИТИЧНО: закриваємо input sessions ДО зміни індексу
        if let currentVC = self.selectedViewController {
            currentVC.view.endEditing(true)
        }
        
        // Тепер змінюємо індекс
        self.selectedIndex = index
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
