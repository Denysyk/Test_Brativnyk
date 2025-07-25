//
//  KeyboardManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol KeyboardManagerDelegate: AnyObject {
    func keyboardWillShow(height: CGFloat, duration: TimeInterval)
    func keyboardWillHide(duration: TimeInterval)
}

class KeyboardManager {
    weak var delegate: KeyboardManagerDelegate?
    
    func setup() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    func cleanup() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        // Detect hardware keyboard and don't trigger delegate if it's hardware keyboard
        let isHardwareKeyboard = detectHardwareKeyboard(height: keyboardFrame.height)
        
        if !isHardwareKeyboard {
            delegate?.keyboardWillShow(height: keyboardFrame.height, duration: duration)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        delegate?.keyboardWillHide(duration: duration)
    }
    
    private func detectHardwareKeyboard(height: CGFloat) -> Bool {
        let screenHeight = UIScreen.main.bounds.height
        
        return height < 100 || // Very small height
               height < screenHeight * 0.15 || // Less than 15% of screen
               isKnownHardwareKeyboardHeight(height)
    }
    
    private func isKnownHardwareKeyboardHeight(_ height: CGFloat) -> Bool {
        let knownHeights: [CGFloat] = [44, 55, 69, 75, 85, 90, 95]
        return knownHeights.contains { abs($0 - height) < 10 }
    }
}
