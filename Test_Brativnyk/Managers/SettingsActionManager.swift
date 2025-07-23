//
//  SettingsActionManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol SettingsActionManagerDelegate: AnyObject {
    func presentAlert(_ alert: UIAlertController)
    func presentActivityController(_ controller: UIActivityViewController)
}

class SettingsActionManager {
    weak var delegate: SettingsActionManagerDelegate?
    
    private let githubURL = "https://github.com/Denysyk/Test_Brativnyk"
    private let contactURL = "https://healthy-metal-aa6.notion.site/iOS-Developer-12831b2ac19680068ac3fcd91252b819?pvs=74"
    
    func performAction(_ action: SettingsAction) {
        switch action {
        case .rateApp:
            handleRateApp()
        case .shareApp:
            handleShareApp()
        case .contactUs:
            handleContactUs()
        }
    }
    
    private func handleRateApp() {
        HapticFeedback.impact(.light)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.showRatingAlert()
        }
    }
    
    private func showRatingAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Rate App", comment: ""),
            message: NSLocalizedString("rate_app_message", comment: ""),
            preferredStyle: .alert
        )
        
        for i in 1...5 {
            let stars = String(repeating: "★", count: i)
            let action = UIAlertAction(title: stars, style: .default) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    self.showThankYouAlert()
                }
            }
            action.setValue(UIColor.systemBlue, forKey: "titleTextColor")
            alert.addAction(action)
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        delegate?.presentAlert(alert)
    }
    
    private func showThankYouAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Thank You!", comment: ""),
            message: NSLocalizedString("thank_you_feedback", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        delegate?.presentAlert(alert)
    }
    
    private func handleShareApp() {
        HapticFeedback.impact(.light)
        
        let shareText = NSLocalizedString("share_app_text", comment: "Check out this amazing app!")
        let fullText = "\(shareText)\n\n\(githubURL)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.showShareSheet(with: fullText)
        }
    }
    
    private func showShareSheet(with text: String) {
        let activityViewController = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        activityViewController.excludedActivityTypes = [
            .assignToContact,
            .saveToCameraRoll,
            .addToReadingList,
            .openInIBooks
        ]
        
        delegate?.presentActivityController(activityViewController)
    }
    
    private func handleContactUs() {
        HapticFeedback.impact(.light)
        
        guard let url = URL(string: contactURL) else {
            showContactFailureAlert()
            return
        }
        
        UIApplication.shared.open(url, options: [:]) { [weak self] success in
            if !success {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self?.showContactFailureAlert()
                }
            }
        }
    }
    
    private func showContactFailureAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Contact Us", comment: ""),
            message: NSLocalizedString("contact_us_fallback_message", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy Link", comment: ""), style: .default) { _ in
            UIPasteboard.general.string = self.contactURL
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showCopiedAlert()
            }
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        delegate?.presentAlert(alert)
    }
    
    private func showCopiedAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Copied!", comment: ""),
            message: nil,
            preferredStyle: .alert
        )
        
        delegate?.presentAlert(alert)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Auto dismiss after 1 second
        }
    }
}
