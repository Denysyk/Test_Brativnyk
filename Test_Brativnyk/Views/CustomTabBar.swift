//
//  CustomTabBar.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

// MARK: - CustomTabBar Protocol
protocol CustomTabBarDelegate: AnyObject {
    func didSelectTab(at index: Int)
}

// MARK: - CustomTabBar Class
class CustomTabBar: UIView {
    
    // MARK: - Properties
    weak var delegate: CustomTabBarDelegate?
    
    private var buttons: [TabBarButton] = []
    private var selectedIndex: Int = 0
    
    private let tabBarItems = TabBarItem.allItems
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        DispatchQueue.main.async {
            self.selectButtonInternal(at: 0)
        }
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 30
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        
        // Add blur effect
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.layer.cornerRadius = 30
        blurView.clipsToBounds = true
        
        insertSubview(blurView, at: 0)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        setupButtons()
    }
    
    private func setupButtons() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        stackView.spacing = 0
        
        for (index, item) in tabBarItems.enumerated() {
            let button = TabBarButton(icon: item.icon, selectedIcon: item.selectedIcon, title: item.title)
            button.tag = index
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            buttons.append(button)
            stackView.addArrangedSubview(button)
        }
        
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func buttonTapped(_ sender: TabBarButton) {
        let index = sender.tag
        
        if index == selectedIndex { return }
        
        selectButtonInternal(at: index)
        delegate?.didSelectTab(at: index)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    // MARK: - Selection Management
    
    private func selectButtonInternal(at index: Int) {
        guard index < buttons.count else { return }
        
        if selectedIndex < buttons.count && selectedIndex != index {
            buttons[selectedIndex].setSelected(false)
        }
        
        selectedIndex = index
        buttons[index].setSelected(true)
    }
    
    func selectButton(at index: Int) {
        selectButtonInternal(at: index)
    }
    
    // MARK: - Theme Support
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            for (index, button) in buttons.enumerated() {
                if index == selectedIndex {
                    button.setSelected(true)
                } else {
                    button.setSelected(false)
                }
            }
        }
    }
}
