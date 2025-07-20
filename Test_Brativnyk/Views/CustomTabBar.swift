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
    
    weak var delegate: CustomTabBarDelegate?
    
    private var buttons: [TabBarButton] = []
    private var selectedIndex: Int = 0
    
    private let tabBarItems = TabBarItem.allItems
    
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
        // Ініціалізуємо перший таб після того, як view буде додано в ієрархію
        DispatchQueue.main.async {
            self.selectButton(at: 0)
        }
    }
    
    private func setupUI() {
        backgroundColor = UIColor.clear
        layer.cornerRadius = 30
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.shadowOpacity = 0.15
        
        // Додаємо blur effect
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
        
        // --- ПОЧАТОК ВИПРАВЛЕННЯ ---
        // Замінюємо жорсткі верхній та нижній констрейнти на центрування по вертикалі.
        // Це дозволяє StackView мати власну висоту (яка визначається висотою кнопок, 48pt),
        // і ця конструкція вільно розміщується всередині TabBar (70pt).
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor) // Вирівнюємо по центру
            // Видалено: topAnchor та bottomAnchor, які викликали конфлікт
        ])
        // --- КІНЕЦЬ ВИПРАВЛЕННЯ ---
    }
    
    @objc private func buttonTapped(_ sender: TabBarButton) {
        let index = sender.tag
        
        if index == selectedIndex { return }
        
        selectButton(at: index)
        delegate?.didSelectTab(at: index)
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    private func selectButton(at index: Int) {
        guard index < buttons.count else { return }
        
        if selectedIndex < buttons.count && selectedIndex != index {
            buttons[selectedIndex].setSelected(false)
        }
        
        selectedIndex = index
        
        buttons[index].setSelected(true)
    }
    
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
