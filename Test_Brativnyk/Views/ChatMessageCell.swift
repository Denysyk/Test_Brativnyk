//
//  ChatMessageCell.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class ChatMessageCell: UITableViewCell {
    static let identifier = "ChatMessageCell"
    
    // MARK: - UI Elements
    private let messageContainerView = UIView()
    private let messageLabel = UILabel()
    private let timeLabel = UILabel()
    private let avatarImageView = UIImageView()
    
    // MARK: - Constraints Properties
    // Create arrays to store constraints that will change
    private var userMessageConstraints: [NSLayoutConstraint] = []
    private var botMessageConstraints: [NSLayoutConstraint] = []
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUIAndBaseConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUIAndBaseConstraints() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Add all UI elements to contentView ONCE
        contentView.addSubview(avatarImageView)
        contentView.addSubview(messageContainerView)
        contentView.addSubview(timeLabel)
        messageContainerView.addSubview(messageLabel)
        
        // Configure element appearance
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFit
        avatarImageView.layer.cornerRadius = 16.0
        avatarImageView.clipsToBounds = true
        
        messageContainerView.translatesAutoresizingMaskIntoConstraints = false
        messageContainerView.layer.cornerRadius = 18.0
        
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.numberOfLines = 0
        messageLabel.font = UIFont.systemFont(ofSize: 16)
        
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.font = UIFont.systemFont(ofSize: 12)
        timeLabel.textColor = UIColor.systemGray
        
        // Create shared constraints (that don't change)
        NSLayoutConstraint.activate([
            avatarImageView.widthAnchor.constraint(equalToConstant: 32),
            avatarImageView.heightAnchor.constraint(equalToConstant: 32),
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            
            messageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            // Limit width so messages don't stretch across entire screen
            messageContainerView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.75),
            
            // Constraints for messageLabel inside messageContainerView
            messageLabel.topAnchor.constraint(equalTo: messageContainerView.topAnchor, constant: 12),
            messageLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor, constant: -16),
            messageLabel.bottomAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: -12),
            
            // Constraints for timeLabel relative to messageContainerView
            timeLabel.topAnchor.constraint(equalTo: messageContainerView.bottomAnchor, constant: 4),
            contentView.bottomAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8)
        ])
        
        // Define constraints for BOT messages (left side)
        botMessageConstraints = [
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            messageContainerView.leadingAnchor.constraint(equalTo: avatarImageView.trailingAnchor, constant: 8),
            timeLabel.leadingAnchor.constraint(equalTo: messageContainerView.leadingAnchor)
        ]
        
        // Define constraints for USER messages (right side)
        userMessageConstraints = [
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            messageContainerView.trailingAnchor.constraint(equalTo: avatarImageView.leadingAnchor, constant: -8),
            timeLabel.trailingAnchor.constraint(equalTo: messageContainerView.trailingAnchor)
        ]
    }
    
    // MARK: - Configuration
    func configure(with message: ChatMessage) {
        messageLabel.text = message.text
        
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        timeLabel.text = formatter.string(from: message.timestamp)
        
        updateLayoutAndAppearance(for: message.type)
    }
    
    private func updateLayoutAndAppearance(for type: MessageType) {
        // Deactivate all variable constraints before setup
        NSLayoutConstraint.deactivate(userMessageConstraints)
        NSLayoutConstraint.deactivate(botMessageConstraints)

        if type == .user {
            // Activate constraints for user
            NSLayoutConstraint.activate(userMessageConstraints)
            
            // Configure appearance for user
            messageContainerView.backgroundColor = UIColor.systemGreen
            messageLabel.textColor = .white
            avatarImageView.image = UIImage(systemName: "person.circle.fill")
            avatarImageView.tintColor = UIColor.systemGreen
            
        } else { // .bot
            // Activate constraints for bot
            NSLayoutConstraint.activate(botMessageConstraints)
            
            // Configure appearance for bot
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
        NSLayoutConstraint.deactivate(userMessageConstraints)
        NSLayoutConstraint.deactivate(botMessageConstraints)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Determine current message type by active constraints and update colors
            if userMessageConstraints.first?.isActive == true {
                updateLayoutAndAppearance(for: .user)
            } else if botMessageConstraints.first?.isActive == true {
                updateLayoutAndAppearance(for: .bot)
            }
        }
    }
}
