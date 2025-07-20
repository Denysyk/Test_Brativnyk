//
//  TabBarButton.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class TabBarButton: UIButton {
    
    private let iconImageView = UIImageView()
    private let customTitleLabel = UILabel()
    private let backgroundView = UIView()
    
    private var isSelectedState = false
    private let buttonTitle: String
    private let normalIcon: String
    private let selectedIcon: String
    
    // Constraints для анімації
    private var widthConstraint: NSLayoutConstraint!
    private var iconCenterXConstraint: NSLayoutConstraint?
    private var iconLeadingConstraint: NSLayoutConstraint?
    
    // Container view для центрування контенту
    private let contentContainer = UIView()
    private let stackView = UIStackView()
    
    init(icon: String, selectedIcon: String, title: String) {
        self.buttonTitle = title
        self.normalIcon = icon
        self.selectedIcon = selectedIcon
        super.init(frame: .zero)
        setupButton(icon: icon, title: title)
    }
    
    required init?(coder: NSCoder) {
        self.buttonTitle = ""
        self.normalIcon = ""
        self.selectedIcon = ""
        super.init(coder: coder)
    }
    
    private func setupButton(icon: String, title: String) {
        // Background view для овального виділення
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.layer.cornerRadius = 20
        addSubview(backgroundView)
        
        // Container для контенту
        contentContainer.isUserInteractionEnabled = false
        addSubview(contentContainer)
        
        // Stack view для горизонтального розташування іконки та тексту
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fill
        contentContainer.addSubview(stackView)
        
        // Іконка
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = getUnselectedIconColor()
        stackView.addArrangedSubview(iconImageView)
        
        // Заголовок
        customTitleLabel.text = NSLocalizedString(title, comment: "")
        customTitleLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        customTitleLabel.textColor = getSelectedTextColor()
        customTitleLabel.alpha = 0
        customTitleLabel.textAlignment = .left
        stackView.addArrangedSubview(customTitleLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Основні constraints для button
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Width constraint - змінюється для анімації
        widthConstraint = widthAnchor.constraint(equalToConstant: 60)
        widthConstraint.isActive = true
        
        // Background view - заповнює всю кнопку
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor, constant: -6),
            backgroundView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Content container - центрується в background view
        NSLayoutConstraint.activate([
            contentContainer.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            contentContainer.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            contentContainer.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 8),
            contentContainer.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -8)
        ])
        
        // Stack view заповнює container
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
        
        // Icon constraints
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        // Встановлюємо пріоритети
        customTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        customTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Ховаємо текст в неактивному стані
        customTitleLabel.isHidden = true
    }
    
    private func getSelectedBackgroundColor() -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor.white.withAlphaComponent(0.15)
        } else {
            return UIColor.black.withAlphaComponent(0.15)
        }
    }
    
    private func getSelectedIconColor() -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    private func getSelectedTextColor() -> UIColor {
        if traitCollection.userInterfaceStyle == .dark {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
    
    private func getUnselectedIconColor() -> UIColor {
        return UIColor.systemGray
    }
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        
        if selected {
            // Спочатку змінюємо іконку та кольори
            iconImageView.image = UIImage(systemName: selectedIcon)
            iconImageView.tintColor = getSelectedIconColor()
            customTitleLabel.textColor = getSelectedTextColor()
            
            // ФІКСОВАНА ширина для всіх виділених кнопок
            let fixedWidth: CGFloat = 100
            
            // Анімація розширення
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.curveEaseInOut]) {
                
                // Змінюємо ширину кнопки на фіксовану
                self.widthConstraint.constant = fixedWidth
                
                // Змінюємо радіус background
                self.backgroundView.layer.cornerRadius = 20
                
                // Фон
                self.backgroundView.backgroundColor = self.getSelectedBackgroundColor()
                
                // Оновлюємо layout
                self.superview?.layoutIfNeeded()
            }
            
            // Анімація появи тексту
            UIView.animate(withDuration: 0.15, delay: 0.15) {
                self.customTitleLabel.isHidden = false
                self.customTitleLabel.alpha = 1
            }
            
        } else {
            // Ховаємо текст
            UIView.animate(withDuration: 0.2) {
                self.customTitleLabel.alpha = 0
            } completion: { _ in
                self.customTitleLabel.isHidden = true
            }
            
            // Анімація стиснення
            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                
                // Повертаємо до стандартної ширини
                self.widthConstraint.constant = 60
                
                // Прибираємо фон
                self.backgroundView.backgroundColor = UIColor.clear
                
                // Оновлюємо layout
                self.superview?.layoutIfNeeded()
                
            } completion: { _ in
                // Змінюємо іконку назад
                self.iconImageView.image = UIImage(systemName: self.normalIcon)
                self.iconImageView.tintColor = self.getUnselectedIconColor()
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        UIView.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            self.transform = .identity
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        
        UIView.animate(withDuration: 0.15, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5) {
            self.transform = .identity
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if isSelectedState {
                backgroundView.backgroundColor = getSelectedBackgroundColor()
                iconImageView.tintColor = getSelectedIconColor()
                customTitleLabel.textColor = getSelectedTextColor()
            } else {
                iconImageView.tintColor = getUnselectedIconColor()
            }
        }
    }
}
