//
//  CustomTabBarManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol CustomTabBarManagerDelegate: AnyObject {
    func didSelectTab(at index: Int)
    func shouldSelectTab(at index: Int) -> Bool
}

class CustomTabBarManager: NSObject {
    weak var delegate: CustomTabBarManagerDelegate?
    
    private weak var parentView: UIView?
    private var customTabBar: CustomTabBar!
    private let animationDuration: TimeInterval = 0.3
    
    init(parentView: UIView) {
        self.parentView = parentView
        super.init()
        setupCustomTabBar()
    }
    
    private func setupCustomTabBar() {
        guard let parentView = parentView else { return }
        
        customTabBar = CustomTabBar()
        customTabBar.delegate = self
        
        parentView.addSubview(customTabBar)
        setupConstraints()
    }
    
    private func setupConstraints() {
        guard let parentView = parentView else { return }
        
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            customTabBar.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 20),
            customTabBar.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -20),
            customTabBar.bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            customTabBar.heightAnchor.constraint(equalToConstant: 70)
        ])
    }
    
    func hideTabBar() {
        UIView.animate(withDuration: animationDuration) {
            self.customTabBar.alpha = 0
            self.customTabBar.transform = CGAffineTransform(translationX: 0, y: 100)
        }
    }
    
    func showTabBar() {
        UIView.animate(withDuration: animationDuration) {
            self.customTabBar.alpha = 1
            self.customTabBar.transform = .identity
        }
    }
    
    func selectTab(at index: Int) {
        customTabBar.selectButton(at: index)
    }
    
    func updateTabBarForKeyboard(show: Bool) {
        if show {
            hideTabBar()
        } else {
            showTabBar()
        }
    }
}

// MARK: - CustomTabBarDelegate
extension CustomTabBarManager: CustomTabBarDelegate {
    func didSelectTab(at index: Int) {
        guard delegate?.shouldSelectTab(at: index) == true else { return }
        delegate?.didSelectTab(at: index)
    }
}
