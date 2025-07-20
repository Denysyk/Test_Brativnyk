//
//  ThemeManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation
import UIKit

class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    // MARK: - Colors
    struct Colors {
        // Background Colors
        static var primaryBackground: UIColor {
            return UIColor.systemBackground
        }
        
        static var secondaryBackground: UIColor {
            return UIColor.secondarySystemBackground
        }
        
        static var tertiaryBackground: UIColor {
            return UIColor.tertiarySystemBackground
        }
        
        // Text Colors
        static var primaryText: UIColor {
            return UIColor.label
        }
        
        static var secondaryText: UIColor {
            return UIColor.secondaryLabel
        }
        
        static var tertiaryText: UIColor {
            return UIColor.tertiaryLabel
        }
        
        // Accent Colors
        static var accent: UIColor {
            return UIColor.systemBlue
        }
        
        static var success: UIColor {
            return UIColor.systemGreen
        }
        
        static var warning: UIColor {
            return UIColor.systemOrange
        }
        
        static var error: UIColor {
            return UIColor.systemRed
        }
        
        // Custom Colors for IP Info
        static var cardBackground: UIColor {
            return UIColor.secondarySystemBackground
        }
        
        static var cardShadow: UIColor {
            return UIColor.label.withAlphaComponent(0.1)
        }
        
        static var mapPin: UIColor {
            return UIColor.systemRed
        }
        
        // Tab Bar Colors
        static var tabBarBackground: UIColor {
            return UIColor.systemBackground.withAlphaComponent(0.95)
        }
        
        static var tabBarSelected: UIColor {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return UIColor.white.withAlphaComponent(0.15)
            } else {
                return UIColor.black.withAlphaComponent(0.15)
            }
        }
        
        static var tabBarSelectedIcon: UIColor {
            if UITraitCollection.current.userInterfaceStyle == .dark {
                return UIColor.white
            } else {
                return UIColor.black
            }
        }
        
        static var tabBarUnselectedIcon: UIColor {
            return UIColor.systemGray
        }
    }
    
    // MARK: - Fonts
    struct Fonts {
        // Headers
        static let largeTitle = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let title1 = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title2 = UIFont.systemFont(ofSize: 22, weight: .bold)
        static let title3 = UIFont.systemFont(ofSize: 20, weight: .semibold)
        
        // Body
        static let headline = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let callout = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let subheadline = UIFont.systemFont(ofSize: 15, weight: .regular)
        static let footnote = UIFont.systemFont(ofSize: 13, weight: .regular)
        static let caption1 = UIFont.systemFont(ofSize: 12, weight: .regular)
        static let caption2 = UIFont.systemFont(ofSize: 11, weight: .regular)
        
        // Custom
        static let tabBarTitle = UIFont.systemFont(ofSize: 13, weight: .medium)
        static let chatMessage = UIFont.systemFont(ofSize: 16, weight: .regular)
        static let ipInfoHeader = UIFont.systemFont(ofSize: 14, weight: .semibold)
        static let ipInfoValue = UIFont.systemFont(ofSize: 16, weight: .medium)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let extraLarge: CGFloat = 20
        static let button: CGFloat = 8
        static let card: CGFloat = 16
        static let tabBar: CGFloat = 30
    }
    
    // MARK: - Shadow
    struct Shadow {
        static let light = ShadowStyle(
            color: UIColor.black.withAlphaComponent(0.1),
            offset: CGSize(width: 0, height: 2),
            radius: 4,
            opacity: 0.1
        )
        
        static let medium = ShadowStyle(
            color: UIColor.black.withAlphaComponent(0.15),
            offset: CGSize(width: 0, height: 4),
            radius: 8,
            opacity: 0.15
        )
        
        static let heavy = ShadowStyle(
            color: UIColor.black.withAlphaComponent(0.2),
            offset: CGSize(width: 0, height: 8),
            radius: 16,
            opacity: 0.2
        )
    }
    
    struct ShadowStyle {
        let color: UIColor
        let offset: CGSize
        let radius: CGFloat
        let opacity: Float
    }
    
    // MARK: - Animation
    struct Animation {
        static let fast: TimeInterval = 0.2
        static let normal: TimeInterval = 0.3
        static let slow: TimeInterval = 0.5
        
        static let springDamping: CGFloat = 0.8
        static let springVelocity: CGFloat = 0.5
    }
    
    // MARK: - Helper Methods
    func applyShadow(to view: UIView, style: ShadowStyle) {
        view.layer.shadowColor = style.color.cgColor
        view.layer.shadowOffset = style.offset
        view.layer.shadowRadius = style.radius
        view.layer.shadowOpacity = style.opacity
    }
    
    func applyCardStyle(to view: UIView) {
        view.backgroundColor = Colors.cardBackground
        view.layer.cornerRadius = CornerRadius.card
        applyShadow(to: view, style: Shadow.light)
    }
    
    // MARK: - Dynamic Color Updates
    func updateColorsForTraitCollection(_ traitCollection: UITraitCollection) {
        // This method can be called when the user interface style changes
        // to update any cached colors or styles
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let themeDidChange = Notification.Name("themeDidChange")
}

// MARK: - UIView Extensions for Theme Support
extension UIView {
    func applyThemeCardStyle() {
        ThemeManager.shared.applyCardStyle(to: self)
    }
    
    func applyThemeShadow(_ style: ThemeManager.ShadowStyle) {
        ThemeManager.shared.applyShadow(to: self, style: style)
    }
}
