//
//  ChatInputManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol ChatInputManagerDelegate: AnyObject {
    func didSendMessage(_ text: String)
}

class ChatInputManager: NSObject {
    weak var delegate: ChatInputManagerDelegate?
    
    let containerView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let placeholderLabel = UILabel()
    
    private var containerBottomConstraint: NSLayoutConstraint!
    private var containerHeightConstraint: NSLayoutConstraint!
    
    private let minHeight: CGFloat = 44
    private let maxHeight: CGFloat = 120
    
    // Hardware keyboard detection
    private var keyboardObserver: NSObjectProtocol?
    private var hasSetAccessoryView = false
    
    override init() {
        super.init()
        setupUI()
        setupKeyboardObserver()
    }
    
    deinit {
        if let observer = keyboardObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func setupUI() {
        containerView.backgroundColor = .clear
        
        setupTextView()
        setupSendButton()
        setupPlaceholder()
    }
    
    private func setupTextView() {
        textView.delegate = self
        textView.layer.cornerRadius = 20
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemBackground
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 60)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.returnKeyType = .send
        textView.enablesReturnKeyAutomatically = true
        
        // Start with no accessory view
        textView.inputAccessoryView = nil
        
        containerView.addSubview(textView)
    }
    
    private func setupSendButton() {
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = UIColor.systemGreen
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        
        containerView.addSubview(sendButton)
    }
    
    private func setupPlaceholder() {
        placeholderLabel.text = NSLocalizedString("Type a message...", comment: "")
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        
        textView.addSubview(placeholderLabel)
    }
    
    private func setupKeyboardObserver() {
        keyboardObserver = NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.handleKeyboardWillShow(notification)
        }
    }
    
    private func handleKeyboardWillShow(_ notification: Notification) {
        guard !hasSetAccessoryView,
              let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else {
            return
        }
        
        let isHardwareKeyboard = detectHardwareKeyboard(height: keyboardFrame.height)
        
        if !isHardwareKeyboard {
            // Only set accessory view for software keyboards
            createAccessoryView()
            textView.reloadInputViews()
        }
        
        hasSetAccessoryView = true
    }
    
    private func detectHardwareKeyboard(height: CGFloat) -> Bool {
        let screenHeight = UIScreen.main.bounds.height
        return height < 100 || height < screenHeight * 0.15
    }
    
    private func createAccessoryView() {
        let accessoryHeight: CGFloat = 40
        textView.inputAccessoryView = KeyboardAccessoryView(height: accessoryHeight) { [weak self] in
            self?.textView.resignFirstResponder()
        }
    }
    
    func setupConstraints(in view: UIView) {
        view.addSubview(containerView)
        
        [containerView, textView, sendButton, placeholderLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        containerBottomConstraint = containerView.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -100
        )
        containerHeightConstraint = containerView.heightAnchor.constraint(equalToConstant: minHeight)
        
        NSLayoutConstraint.activate([
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerBottomConstraint,
            containerHeightConstraint,
            
            textView.topAnchor.constraint(equalTo: containerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -8),
            sendButton.widthAnchor.constraint(equalToConstant: 40),
            sendButton.heightAnchor.constraint(equalToConstant: 40),
            
            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 10),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8)
        ])
    }
    
    func adjustForKeyboard(height: CGFloat, duration: TimeInterval) {
        if height == 0 {
            containerBottomConstraint.constant = -100
            hasSetAccessoryView = false // Reset for next keyboard appearance
        } else {
            let safeAreaBottom = containerView.superview?.safeAreaInsets.bottom ?? 0
            containerBottomConstraint.constant = -height - 8 + safeAreaBottom
        }
        
        UIView.animate(withDuration: duration) {
            self.containerView.superview?.layoutIfNeeded()
        }
    }
    
    func clearText() {
        textView.text = ""
        textViewDidChange(textView)
    }
    
    @objc private func sendButtonTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        delegate?.didSendMessage(text)
        clearText()
    }
    
    private func updateHeight() {
        let textWidth = textView.frame.width - textView.textContainerInset.left - textView.textContainerInset.right
        guard textWidth > 0 else { return }
        
        let size = textView.sizeThatFits(CGSize(width: textWidth, height: .greatestFiniteMagnitude))
        let newHeight = max(minHeight, min(maxHeight, size.height))
        
        if abs(containerHeightConstraint.constant - newHeight) > 2 {
            containerHeightConstraint.constant = newHeight
            textView.isScrollEnabled = newHeight >= maxHeight
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.containerView.superview?.layoutIfNeeded()
            }
        }
    }
}

extension ChatInputManager: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isEnabled = hasText
        sendButton.alpha = hasText ? 1.0 : 0.5
        
        updateHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
}
