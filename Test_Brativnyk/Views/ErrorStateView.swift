//
//  ErrorStateView.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol ErrorStateViewDelegate: AnyObject {
    func didTapRetry()
}

class ErrorStateView: UIView {
    
    weak var delegate: ErrorStateViewDelegate?
    
    private let iconImageView = UIImageView()
    private let messageLabel = UILabel()
    private let retryButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.systemBackground
        layer.cornerRadius = 16
        isHidden = true
        
        setupIconImageView()
        setupMessageLabel()
        setupRetryButton()
        setupConstraints()
    }
    
    private func setupIconImageView() {
        iconImageView.image = UIImage(systemName: "exclamationmark.triangle")
        iconImageView.tintColor = UIColor.systemOrange
        iconImageView.contentMode = .scaleAspectFit
        addSubview(iconImageView)
    }
    
    private func setupMessageLabel() {
        messageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        messageLabel.textColor = UIColor.label
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)
    }
    
    private func setupRetryButton() {
        retryButton.setTitle(NSLocalizedString("retry", comment: ""), for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.backgroundColor = UIColor.systemBlue
        retryButton.layer.cornerRadius = 8
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        addSubview(retryButton)
    }
    
    private func setupConstraints() {
        [iconImageView, messageLabel, retryButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            iconImageView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
            iconImageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            messageLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            
            retryButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44),
            retryButton.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -20)
        ])
    }
    
    func show(message: String) {
        messageLabel.text = message
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    @objc private func retryButtonTapped() {
        delegate?.didTapRetry()
        HapticFeedback.impact(.light)
    }
}
