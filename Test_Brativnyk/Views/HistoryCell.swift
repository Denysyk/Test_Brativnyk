//
//  HistoryCell.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit
import CoreData

class HistoryCell: UITableViewCell {
    static let identifier = "HistoryCell"
    
    // MARK: - UI Elements
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let timeLabel = UILabel()
    private let messageCountLabel = UILabel()
    private let chevronImageView = UIImageView()
    
    // MARK: - Initialization
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // Container View
        containerView.backgroundColor = UIColor.systemBackground
        containerView.layer.cornerRadius = 16
        containerView.layer.shadowColor = UIColor.label.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.1
        contentView.addSubview(containerView)
        
        // Icon
        iconImageView.image = UIImage(systemName: "message.circle.fill")
        iconImageView.tintColor = UIColor.systemGreen
        iconImageView.contentMode = .scaleAspectFit
        containerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        titleLabel.textColor = UIColor.label
        titleLabel.numberOfLines = 1
        containerView.addSubview(titleLabel)
        
        // Subtitle Label
        subtitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        subtitleLabel.textColor = UIColor.systemGray
        subtitleLabel.numberOfLines = 1
        containerView.addSubview(subtitleLabel)
        
        // Time Label
        timeLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        timeLabel.textColor = UIColor.systemGray2
        timeLabel.textAlignment = .right
        containerView.addSubview(timeLabel)
        
        // Message Count Badge
        messageCountLabel.font = UIFont.systemFont(ofSize: 11, weight: .bold)
        messageCountLabel.textColor = .white
        messageCountLabel.backgroundColor = UIColor.systemOrange
        messageCountLabel.textAlignment = .center
        messageCountLabel.layer.cornerRadius = 10
        messageCountLabel.clipsToBounds = true
        containerView.addSubview(messageCountLabel)
        
        // Chevron
        chevronImageView.image = UIImage(systemName: "chevron.right")
        chevronImageView.tintColor = UIColor.systemGray3
        chevronImageView.contentMode = .scaleAspectFit
        containerView.addSubview(chevronImageView)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        containerView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        messageCountLabel.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Container View
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            // Icon
            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 32),
            iconImageView.heightAnchor.constraint(equalToConstant: 32),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: -8),
            
            // Subtitle Label
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 2),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: messageCountLabel.leadingAnchor, constant: -8),
            subtitleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
            // Time Label
            timeLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            timeLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -8),
            timeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 50),
            
            // Message Count Badge
            messageCountLabel.centerYAnchor.constraint(equalTo: subtitleLabel.centerYAnchor),
            messageCountLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            messageCountLabel.widthAnchor.constraint(equalToConstant: 20),
            messageCountLabel.heightAnchor.constraint(equalToConstant: 20),
            
            // Chevron
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 12),
            chevronImageView.heightAnchor.constraint(equalToConstant: 12)
        ])
    }
    
    // MARK: - Configuration
    func configure(with chatSession: ChatSession) {
        // Title
        titleLabel.text = chatSession.title ?? NSLocalizedString("New Chat", comment: "")
        
        // Subtitle (перше повідомлення або опис)
        if let messages = chatSession.messages as? Set<Message>,
           let firstMessage = messages.sorted(by: { $0.timestamp ?? Date() < $1.timestamp ?? Date() }).first {
            let messageText = firstMessage.text ?? ""
            subtitleLabel.text = String(messageText.prefix(60)) + (messageText.count > 60 ? "..." : "")
        } else {
            subtitleLabel.text = NSLocalizedString("No messages", comment: "")
        }
        
        // Time - показуємо дату створення чату у форматі дати
        if let createdAt = chatSession.createdAt {
            timeLabel.text = formatDateOnly(createdAt)
        } else {
            timeLabel.text = ""
        }
        
        // Message count
        let messageCount = chatSession.messages?.count ?? 0
        if messageCount > 0 {
            messageCountLabel.text = "\(messageCount)"
            messageCountLabel.isHidden = false
        } else {
            messageCountLabel.isHidden = true
        }
        
        // Уніфіковані іконки - всі зелені
        iconImageView.image = UIImage(systemName: "message.circle.fill")
        iconImageView.tintColor = UIColor.systemGreen
    }
    
    // MARK: - Helper Methods
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            return formatter.string(from: date)
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return NSLocalizedString("Yesterday", comment: "")
        } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(date) == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            return formatter.string(from: date)
        }
    }
    
    private func formatDateOnly(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return NSLocalizedString("Today", comment: "")
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return NSLocalizedString("Yesterday", comment: "")
        } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(date) == true {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            return formatter.string(from: date)
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy"
            return formatter.string(from: date)
        }
    }
    
    private func isRecent(_ date: Date?) -> Bool {
        guard let date = date else { return false }
        let daysSinceUpdate = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        return daysSinceUpdate <= 1
    }
    
    // MARK: - Animation
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.containerView.transform = highlighted ? CGAffineTransform(scaleX: 0.95, y: 0.95) : .identity
            self.containerView.layer.shadowOpacity = highlighted ? 0.2 : 0.1
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        timeLabel.text = nil
        messageCountLabel.text = nil
        messageCountLabel.isHidden = false
        iconImageView.image = nil
        containerView.transform = .identity
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            containerView.layer.shadowColor = UIColor.label.cgColor
        }
    }
}
