//
//  HistoryViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit
import CoreData

class HistoryViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let emptyStateView = UIView()
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    private let emptyStateSubtitleLabel = UILabel()
    
    // MARK: - Properties
    private var chatSessions: [ChatSession] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        loadChatSessions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadChatSessions() // Оновлюємо дані при поверненні на екран
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = NSLocalizedString("History", comment: "")
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.showsVerticalScrollIndicator = false
        view.addSubview(tableView)
        
        // Empty State View
        setupEmptyStateView()
        view.addSubview(emptyStateView)
        
        // Navigation Bar
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        // Кнопка очищення всієї історії
        let clearAllButton = UIButton(type: .system)
        
        var config = UIButton.Configuration.borderless()
        config.baseForegroundColor = UIColor.systemRed
        config.title = NSLocalizedString("Clear All", comment: "")
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            return outgoing
        }
        
        clearAllButton.configuration = config
        clearAllButton.addTarget(self, action: #selector(clearAllButtonTapped), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: clearAllButton)
    }
    
    private func setupEmptyStateView() {
        emptyStateView.backgroundColor = .clear
        
        // Image
        emptyStateImageView.image = UIImage(systemName: "clock.badge.xmark")
        emptyStateImageView.tintColor = UIColor.systemGray3
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(emptyStateImageView)
        
        // Main Label
        emptyStateLabel.text = NSLocalizedString("No Chat History", comment: "")
        emptyStateLabel.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        emptyStateLabel.textColor = UIColor.label
        emptyStateLabel.textAlignment = .center
        emptyStateView.addSubview(emptyStateLabel)
        
        // Subtitle Label
        emptyStateSubtitleLabel.text = NSLocalizedString("Start a conversation to see your chat history here", comment: "")
        emptyStateSubtitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        emptyStateSubtitleLabel.textColor = UIColor.systemGray
        emptyStateSubtitleLabel.textAlignment = .center
        emptyStateSubtitleLabel.numberOfLines = 0
        emptyStateView.addSubview(emptyStateSubtitleLabel)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80), // Відступ для таб-бару
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Empty State Image
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 80),
            
            // Empty State Label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 20),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            
            // Empty State Subtitle
            emptyStateSubtitleLabel.topAnchor.constraint(equalTo: emptyStateLabel.bottomAnchor, constant: 8),
            emptyStateSubtitleLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateSubtitleLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateSubtitleLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    // MARK: - Data Methods
    private func loadChatSessions() {
        chatSessions = CoreDataManager.shared.getAllChatSessions()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
            self.updateNavigationBar()
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = chatSessions.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func updateNavigationBar() {
        navigationItem.rightBarButtonItem?.customView?.isHidden = chatSessions.isEmpty
    }
    
    private func deleteChatSession(at index: Int) {
        guard index < chatSessions.count else { return }
        
        let sessionToDelete = chatSessions[index]
        
        // Видаляємо з Core Data
        CoreDataManager.shared.deleteChatSession(sessionToDelete)
        
        // Видаляємо з масиву
        chatSessions.remove(at: index)
        
        // Оновлюємо UI
        tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        
        // Перевіряємо чи потрібно показати empty state
        if chatSessions.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updateEmptyState()
                self.updateNavigationBar()
            }
        }
    }
    
    private func openChatSession(_ session: ChatSession) {
        guard let chatId = session.id else { return }
        
        // Переходимо на таб чату
        if let tabBarController = tabBarController as? TabBarController {
            // Спочатку переключаємо таб на чат (індекс 0)
            tabBarController.selectedIndex = 0
            
            // Отримуємо ChatViewController і завантажуємо потрібний чат
            if let navController = tabBarController.viewControllers?[0] as? UINavigationController,
               let chatViewController = navController.topViewController as? ChatViewController {
                
                // Додаємо невелику затримку для плавного переходу та активації табу
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    chatViewController.loadChatWithId(chatId)
                }
            }
        }
    }
    
    // MARK: - Actions
    @objc private func clearAllButtonTapped() {
        let alert = UIAlertController(
            title: NSLocalizedString("Clear All History", comment: ""),
            message: NSLocalizedString("This will permanently delete all your chat conversations. This action cannot be undone.", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Clear All", comment: ""), style: .destructive) { _ in
            self.clearAllHistory()
        })
        
        present(alert, animated: true)
    }
    
    private func clearAllHistory() {
        // Видаляємо всі дані з Core Data
        CoreDataManager.shared.deleteAllData()
        
        // Очищуємо масив
        chatSessions.removeAll()
        
        // Оновлюємо UI з анімацією
        UIView.animate(withDuration: 0.3) {
            self.tableView.alpha = 0
        } completion: { _ in
            self.tableView.reloadData()
            self.updateEmptyState()
            self.updateNavigationBar()
            
            UIView.animate(withDuration: 0.3) {
                self.tableView.alpha = 1
            }
        }
        
        // Haptic feedback
        let notificationFeedback = UINotificationFeedbackGenerator()
        notificationFeedback.notificationOccurred(.success)
    }
}

// MARK: - UITableViewDataSource
extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatSessions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: HistoryCell.identifier, for: indexPath) as! HistoryCell
        cell.configure(with: chatSessions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteChatSession(at: indexPath.row)
        }
    }
}

// MARK: - UITableViewDelegate
extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let session = chatSessions[indexPath.row]
        openChatSession(session)
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    // Swipe actions
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { [weak self] _, _, completion in
            self?.deleteChatSession(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
