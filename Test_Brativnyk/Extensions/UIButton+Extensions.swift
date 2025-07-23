//
//  UIButton+Extensions.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

extension UIButton {
    static func createNavigationButton(image: String, target: Any?, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.borderless()
        config.baseForegroundColor = UITraitCollection.current.userInterfaceStyle == .dark ? .white : .black
        config.image = UIImage(systemName: image)?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        )
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        button.configuration = config
        button.addTarget(target, action: action, for: .touchUpInside)
        
        return button
    }
}
