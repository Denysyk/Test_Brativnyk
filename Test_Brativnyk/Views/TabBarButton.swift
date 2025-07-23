//
//  TabBarButton.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class TabBarButton: UIButton {
    
    // MARK: - UI Elements
    private let iconImageView = UIImageView()
    private let customTitleLabel = UILabel()
    private let backgroundView = UIView()
    
    // MARK: - Properties
    private var isSelectedState = false
    private let buttonTitle: String
    private let normalIcon: String
    private let selectedIcon: String
    
    // Constraints for animation
    private var widthConstraint: NSLayoutConstraint!
    
    // Container view for centering content
    private let contentContainer = UIView()
    private let stackView = UIStackView()
    
    // MARK: - Initialization
    
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
    
    // MARK: - Setup
    
    private func setupButton(icon: String, title: String) {
        // Background view for oval selection
        backgroundView.isUserInteractionEnabled = false
        backgroundView.backgroundColor = UIColor.clear
        backgroundView.layer.cornerRadius = 20
        addSubview(backgroundView)
        
        // Container for content
        contentContainer.isUserInteractionEnabled = false
        addSubview(contentContainer)
        
        // Stack view for horizontal layout of icon and text
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .fill
        contentContainer.addSubview(stackView)
        
        // Icon
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = getUnselectedIconColor()
        stackView.addArrangedSubview(iconImageView)
        
        // Title
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
        
        // Basic constraints for button
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 48)
        ])
        
        // Width constraint - changes for animation
        widthConstraint = widthAnchor.constraint(equalToConstant: 60)
        widthConstraint.isActive = true
        
        // Background view - fills entire button
        NSLayoutConstraint.activate([
            backgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            backgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            backgroundView.widthAnchor.constraint(equalTo: widthAnchor, constant: -6),
            backgroundView.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        // Content container - centered in background view
        NSLayoutConstraint.activate([
            contentContainer.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
            contentContainer.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor),
            contentContainer.leadingAnchor.constraint(greaterThanOrEqualTo: backgroundView.leadingAnchor, constant: 8),
            contentContainer.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -8)
        ])
        
        // Stack view fills container
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
        
        // Set priorities
        customTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        customTitleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        // Hide text in inactive state
        customTitleLabel.isHidden = true
    }
    
    // MARK: - Color Methods
    
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
    
    // MARK: - Selection State
    
    func setSelected(_ selected: Bool) {
        isSelectedState = selected
        
        if selected {
            // First change icon and colors
            iconImageView.image = UIImage(systemName: selectedIcon)
            iconImageView.tintColor = getSelectedIconColor()
            customTitleLabel.textColor = getSelectedTextColor()
            
            // Fixed width for all selected buttons
            let fixedWidth: CGFloat = 140
            
            // Expansion animation
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2, options: [.curveEaseInOut]) {
                
                // Change button width to fixed
                self.widthConstraint.constant = fixedWidth
                
                // Change background radius
                self.backgroundView.layer.cornerRadius = 20
                
                // Background
                self.backgroundView.backgroundColor = self.getSelectedBackgroundColor()
                
                // Update layout
                self.superview?.layoutIfNeeded()
            }
            
            // Text appearance animation
            UIView.animate(withDuration: 0.15, delay: 0.15) {
                self.customTitleLabel.isHidden = false
                self.customTitleLabel.alpha = 1
            }
            
        } else {
            // Hide text
            UIView.animate(withDuration: 0.2) {
                self.customTitleLabel.alpha = 0
            } completion: { _ in
                self.customTitleLabel.isHidden = true
            }
            
            // Compression animation
            UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.2) {
                
                // Return to standard width
                self.widthConstraint.constant = 60
                
                // Remove background
                self.backgroundView.backgroundColor = UIColor.clear
                
                // Update layout
                self.superview?.layoutIfNeeded()
                
            } completion: { _ in
                // Change icon back
                self.iconImageView.image = UIImage(systemName: self.normalIcon)
                self.iconImageView.tintColor = self.getUnselectedIconColor()
            }
        }
    }
    
    // MARK: - Touch Handling
    
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
    
    // MARK: - Theme Support
    
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
