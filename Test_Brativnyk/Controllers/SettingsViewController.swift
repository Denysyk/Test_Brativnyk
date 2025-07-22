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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // FIXED: Більш агресивна очистка input sessions згідно з форумами
        DispatchQueue.main.async {
            // Очищуємо всі можливі firstResponders в ієрархії
            self.view.endEditing(true)
            
            // Додаткова перевірка для TabBarController
            if let tabBar = self.tabBarController {
                tabBar.view.endEditing(true)
            }
        }
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
                textColor: UIColor.label
            )
        ]
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    private func rateApp() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // Просто зірочки без зайвого
        showSimpleStarRating()
    }
    
    // FIXED: Оновлений метод showSimpleStarRating згідно з форумами
    private func showSimpleStarRating() {
        // FIXED: Агресивна очистка всіх input sessions перед показом алерту
        if let tabBar = tabBarController {
            tabBar.view.endEditing(true)
        }
        view.endEditing(true)
        
        // FIXED: Збільшена затримка для повного завершення input operations
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let alert = UIAlertController(
                title: NSLocalizedString("Rate App", comment: ""),
                message: NSLocalizedString("rate_app_message", comment: ""),
                preferredStyle: .alert
            )
            
            // 5 синіх зірочок star.fill
            for i in 1...5 {
                let stars = String(repeating: "★", count: i)
                
                let action = UIAlertAction(title: stars, style: .default) { _ in
                    self.showSimpleThankYou()
                }
                
                action.setValue(UIColor.systemBlue, forKey: "titleTextColor")
                alert.addAction(action)
            }
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            
            self.present(alert, animated: true)
        }
    }
    
    // FIXED: Оновлений метод showSimpleThankYou
    private func showSimpleThankYou() {
        // FIXED: Додаємо затримку перед показом наступного алерту
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = UIAlertController(
                title: NSLocalizedString("Thank You!", comment: ""),
                message: NSLocalizedString("thank_you_feedback", comment: ""),
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true)
        }
    }
    
    private func shareApp() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // FIXED: Прибираємо input sessions перед показом share sheet
        view.endEditing(true)
        
        // Створюємо текст для поділу замість прямого URL
        let shareText = NSLocalizedString("share_app_text", comment: "Check out this amazing app!")
        let githubURL = "https://github.com/Denysyk/Test_Brativnyk"
        let fullText = "\(shareText)\n\n\(githubURL)"
        
        // FIXED: Додаємо затримку перед показом activity controller
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Створюємо activity controller з текстом замість URL об'єкта
            let activityViewController = UIActivityViewController(
                activityItems: [fullText],
                applicationActivities: nil
            )
            
            // Виключаємо деякі активності, які можуть викликати проблеми
            activityViewController.excludedActivityTypes = [
                .assignToContact,
                .saveToCameraRoll,
                .addToReadingList,
                .openInIBooks
            ]
            
            // Для iPad
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = self.view
                popover.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            self.present(activityViewController, animated: true)
        }
    }
    
    // FIXED: Оновлений метод contactUs
    private func contactUs() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        // FIXED: Прибираємо всі input sessions
        view.endEditing(true)
        
        let contactURL = "https://healthy-metal-aa6.notion.site/iOS-Developer-12831b2ac19680068ac3fcd91252b819?pvs=74"
        
        if let url = URL(string: contactURL) {
            UIApplication.shared.open(url, options: [:]) { [weak self] success in
                DispatchQueue.main.async {
                    if !success {
                        self?.showContactFailureAlert()
                    }
                }
            }
        } else {
            showContactFailureAlert()
        }
    }
    
    // FIXED: Оновлений метод showContactFailureAlert
    private func showContactFailureAlert() {
        // FIXED: Додаємо затримку та прибираємо input sessions
        view.endEditing(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            let alert = UIAlertController(
                title: NSLocalizedString("Contact Us", comment: ""),
                message: NSLocalizedString("contact_us_fallback_message", comment: ""),
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Copy Link", comment: ""), style: .default) { _ in
                UIPasteboard.general.string = "https://healthy-metal-aa6.notion.site/iOS-Developer-12831b2ac19680068ac3fcd91252b819?pvs=74"
                
                // FIXED: Додаємо затримку перед показом copied alert
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    let copiedAlert = UIAlertController(title: NSLocalizedString("Copied!", comment: ""), message: nil, preferredStyle: .alert)
                    self.present(copiedAlert, animated: true)
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        copiedAlert.dismiss(animated: true)
                    }
                }
            })
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default))
            self.present(alert, animated: true)
        }
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
        
        // FIXED: Прибираємо input sessions перед виконанням action
        view.endEditing(true)
        
        let item = settingsItems[indexPath.row]
        
        // FIXED: Додаємо затримку перед виконанням action
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            item.action()
        }
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
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor.systemGray
        contentView.addSubview(iconImageView)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        titleLabel.textColor = UIColor.label
        contentView.addSubview(titleLabel)
        
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
