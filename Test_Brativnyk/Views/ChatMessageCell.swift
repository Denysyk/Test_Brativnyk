//
//  ChatMessageCell.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    private let messageContainerView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    private var currentMessageType: MessageType?
    private var constraintsSetup = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Avatar
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 16.0
        avatarImageView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        
        // Container для повідомлення
        messageContainerView.layer.cornerRadius = 16.0
        messageContainerView.clipsToBounds = true
        contentView.addSubview(messageContainerView)
        
        // Текст повідомлення
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        messageContainerView.addSubview(messageLabel)
        
        // Час
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.systemGray
        contentView.addSubview(timeLabel)
        
        setupBaseConstraints()
    }
    
    private func setupBaseConstraints() {
        guard !constraintsSetup else { return }
        
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Avatar constraints
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        ])
        
        // Message container basic constraints
        NSLayoutConstraint.activate([
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            messageContainerView.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
            messageContainerView.widthAnchor.constraint(greaterThanOrEqualToConstant: 50)
        ])
        
        // Message label constraints
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -12)
        ])
        
        // Time label constraints
        NSLayoutConstraint.activate([
            timeLabel.topAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: 4),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])
        
        constraintsSetup = true
    }
    
    func configure(with message: ChatMessage) {
        // Встановлюємо контент
        messageLabel.text = message.text
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        // Якщо тип повідомлення змінився, оновлюємо layout
        if currentMessageType != message.type {
            currentMessageType = message.type
            updateLayoutForMessageType(message.type)
        }
        
        // Встановлюємо кольори та іконки
        updateAppearanceForMessageType(message.type)
    }
    
    private func updateLayoutForMessageType(_ type: MessageType) {
        // Очищуємо тільки змінні constraints, не усі
        avatarImageView.removeFromSuperview()
        messageContainerView.removeFromSuperview()
        timeLabel.removeFromSuperview()
        
        // Додаємо елементи назад
        contentView.addSubview(avatarImageView)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(timeLabel)
        
        // Скидаємо translatesAutoresizingMaskIntoConstraints
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Встановлюємо базові constraints
        constraintsSetup = false
        setupBaseConstraints()
        
        switch type {
        case .user:
            setupUserConstraints()
        case .bot:
            setupBotConstraints()
        }
    }
    
    private func setupUserConstraints() {
        NSLayoutConstraint.activate([
            // Avatar справа
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // Message container зліва від avatar
            messageContainerView.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8),
            messageContainerView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 60),
            
            // Time label вирівняний по правому краю container
            timeLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor)
        ])
    }
    
    private func setupBotConstraints() {
        NSLayoutConstraint.activate([
            // Avatar зліва
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            
            // Message container справа від avatar
            messageContainerView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            messageContainerView.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -60),
            
            // Time label вирівняний по лівому краю container
            timeLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor)
        ])
    }
    
    private func updateAppearanceForMessageType(_ type: MessageType) {
        switch type {
        case .user:
            messageContainerView.backgroundColor = UIColor.systemGreen
            messageLabel.textColor = .white
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = UIColor.systemGreen
            
        case .bot:
            if traitCollection.userInterfaceStyle == .dark {
                messageContainerView.backgroundColor = UIColor.systemGray5
                messageLabel.textColor = .white
            } else {
                messageContainerView.backgroundColor = UIColor.systemGray6
                messageLabel.textColor = .black
            }
            avatarImageView.image = UIImage(systemName: "brain.head.profile")
            avatarImageView.tintColor = UIColor.systemPurple
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        currentMessageType = nil
        messageLabel.text = nil
        timeLabel.text = nil
        constraintsSetup = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            if let messageType = currentMessageType {
                updateAppearanceForMessageType(messageType)
            }
        }
    }
}
