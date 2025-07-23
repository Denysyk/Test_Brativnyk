//
//  KeyboardAccessoryView.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class KeyboardAccessoryView: UIView {
    private let onDismiss: () -> Void
    
    init(height: CGFloat = 40, onDismiss: @escaping () -> Void) {
        self.onDismiss = onDismiss
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: height))
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
        addSubview(blurView)
        
        let dismissButton = UIButton(type: .system)
        dismissButton.setImage(UIImage(systemName: "keyboard.chevron.compact.down"), for: .normal)
        dismissButton.tintColor = UIColor.label
        dismissButton.backgroundColor = UIColor.secondarySystemBackground
        dismissButton.layer.cornerRadius = 6
        dismissButton.addTarget(self, action: #selector(dismissTapped), for: .touchUpInside)
        addSubview(dismissButton)
        
        let separator = UIView()
        separator.backgroundColor = UIColor.separator
        addSubview(separator)
        
        [blurView, dismissButton, separator].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            separator.topAnchor.constraint(equalTo: topAnchor),
            separator.leadingAnchor.constraint(equalTo: leadingAnchor),
            separator.trailingAnchor.constraint(equalTo: trailingAnchor),
            separator.heightAnchor.constraint(equalToConstant: 0.5),
            
            dismissButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            dismissButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            dismissButton.widthAnchor.constraint(equalToConstant: 36),
            dismissButton.heightAnchor.constraint(equalToConstant: 28)
        ])
    }
    
    @objc private func dismissTapped() {
        HapticFeedback.impact(.light)
        onDismiss()
    }
}
