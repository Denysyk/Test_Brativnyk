//
//  SettingsViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit
import StoreKit

struct SettingsItem {
    let title: String
    let icon: String
    let action: () -> Void
    let accessoryType: UITableViewCell.AccessoryType
    let textColor: UIColor
}

class SettingsViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - Properties
    private var settingsItems: [SettingsItem] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSettingsItems()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = NSLocalizedString("Settings", comment: "")
        
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        tableView.rowHeight = 60
        tableView.sectionHeaderHeight = 40
        tableView.sectionFooterHeight = 20
        
        // Register cell
        tableView.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }
    
    private func setupSettingsItems() {
        settingsItems = [
            SettingsItem(
                title: NSLocalizedString("Rate App", comment: ""),
                icon: "star.fill",
                action: { [weak self] in
                    self?.rateApp()
                },
                accessoryType: .disclosureIndicator,
                textColor: UIColor.label
            ),
            SettingsItem(
                title: NSLocalizedString("Share App", comment: ""),
                icon: "square.and.arrow.up",
                action: { [weak self] in
                    self?.shareApp()
                },
                accessoryType: .disclosureIndicator,
                textColor: UIColor.label
            ),
            SettingsItem(
                title: NSLocalizedString("Contact Us", comment: ""),
                icon: "envelope.fill",
                action: { [weak self] in
                    self?.contactUs()
                },
                accessoryType: .disclosureIndicator,
                textColor: UIColor.label  // Змінено з systemBlue на label
            )
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    private func rateApp() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Show simple rating alert with emojis
        showSimpleRatingAlert()
    }
    
    private func showSimpleRatingAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Rate App", comment: ""),
            message: NSLocalizedString("rate_app_message", comment: ""),
            preferredStyle: .alert
        )
        
        // Add rating options with stars
        for i in 1...5 {
            let stars = String(repeating: "⭐", count: i)
            let title = "\(stars) (\(i)/5)"
            
            alert.addAction(UIAlertAction(title: title, style: .default) { _ in
                self.showRatingThankYou(stars: i)
            })
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        
        present(alert, animated: true)
    }
    
    private func showRatingThankYou(stars: Int) {
        let message = stars >= 4 ?
            NSLocalizedString("thank_you_good_rating", comment: "") :
            NSLocalizedString("thank_you_feedback", comment: "")
        
        let alert = UIAlertController(
            title: NSLocalizedString("Thank You!", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        
        if stars >= 4 {
            alert.addAction(UIAlertAction(title: NSLocalizedString("Rate on App Store", comment: ""), style: .default) { _ in
                self.openAppStore()
            })
        }
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        
        present(alert, animated: true)
    }
    
    private func openAppStore() {
        // В реальному додатку тут буде твій App Store ID
        let appStoreURL = "https://apps.apple.com/app/id123456789" // замініти на реальний
        
        if let url = URL(string: appStoreURL) {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        let shareText = NSLocalizedString("share_app_text", comment: "")
        let appURL = "https://apps.apple.com/app/id123456789" // замініти на реальний
        
        let activityViewController = UIActivityViewController(
            activityItems: [shareText, appURL],
            applicationActivities: nil
        )
        
        // Для iPad
        if let popover = activityViewController.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
        }
        
        present(activityViewController, animated: true)
    }
    
    private func contactUs() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Твоє реальне посилання на Notion з завданням
        let contactURL = "https://healthy-metal-aa6.notion.site/iOS-Developer-12831b2ac19680068ac3fcd91252b819?pvs=74"
        
        if let url = URL(string: contactURL) {
            UIApplication.shared.open(url) { success in
                if !success {
                    // Якщо не вдалося відкрити, показуємо алерт
                    DispatchQueue.main.async {
                        self.showContactFailureAlert()
                    }
                }
            }
        } else {
            showContactFailureAlert()
        }
    }
    
    private func showContactFailureAlert() {
        let alert = UIAlertController(
            title: NSLocalizedString("Contact Us", comment: ""),
            message: NSLocalizedString("contact_us_fallback_message", comment: ""),
            preferredStyle: .alert
        )
        
        // Копіювати посилання в буфер
        alert.addAction(UIAlertAction(title: NSLocalizedString("Copy Link", comment: ""), style: .default) { _ in
            UIPasteboard.general.string = "https://healthy-metal-aa6.notion.site/iOS-Developer-12831b2ac19680068ac3fcd91252b819?pvs=74"
            
            // Показуємо короткий алерт про копіювання
            let copiedAlert = UIAlertController(title: NSLocalizedString("Copied!", comment: ""), message: nil, preferredStyle: .alert)
            self.present(copiedAlert, animated: true)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                copiedAlert.dismiss(animated: true)
            }
        })
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
        let item = settingsItems[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("App Settings", comment: "")
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return NSLocalizedString("Version", comment: "") + " \(version) (\(build))"
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = settingsItems[indexPath.row]
        item.action()
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.textLabel?.textColor = UIColor.secondaryLabel
            header.textLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footer = view as? UITableViewHeaderFooterView {
            footer.textLabel?.textColor = UIColor.tertiaryLabel
            footer.textLabel?.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            footer.textLabel?.textAlignment = .center
        }
    }
}

// MARK: - Custom Table View Cell
class SettingsTableViewCell: UITableViewCell {
    static let identifier = "SettingsTableViewCell"
    
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemGroupedBackground
        
        // Icon
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.systemBlue
        contentView.addSubview(iconImageView)
        
        // Title
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor.label
        contentView.addSubview(titleLabel)
        
        // Constraints
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 28),
            iconImageView.heightAnchor.constraint(equalToConstant: 28),
            
            titleLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with item: SettingsItem) {
        iconImageView.image = UIImage(systemName: item.icon)
        titleLabel.text = item.title
        titleLabel.textColor = item.textColor
        accessoryType = item.accessoryType
        
        // All icons are gray now
        iconImageView.tintColor = UIColor.systemGray
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        UIView.animate(withDuration: 0.1) {
            self.alpha = highlighted ? 0.7 : 1.0
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        titleLabel.text = nil
        titleLabel.textColor = UIColor.label
        iconImageView.tintColor = UIColor.systemGray
        accessoryType = .none
    }
}
