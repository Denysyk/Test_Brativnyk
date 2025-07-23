//
//  HistoryViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class HistoryViewController: UIViewController, HistoryDataManagerDelegate, HistoryTableManagerDelegate {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let emptyStateView = HistoryEmptyStateView()
    
    // MARK: - Managers
    private let dataManager = HistoryDataManager()
    private lazy var tableManager = HistoryTableManager(tableView: tableView)
    private lazy var navigationManager = HistoryNavigationManager(viewController: self)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupDelegates()
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = NSLocalizedString("History", comment: "")
        
        setupTableView()
        setupEmptyState()
        setupNavigationBar()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    private func setupEmptyState() {
        view.addSubview(emptyStateView)
    }
    
    private func setupNavigationBar() {
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
    
    private func setupConstraints() {
        [tableView, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func setupDelegates() {
        dataManager.delegate = self
        tableManager.delegate = self
    }
    
    // MARK: - Data Methods
    private func loadData() {
        dataManager.loadChatSessions()
    }
    
    private func updateEmptyState() {
        let isEmpty = dataManager.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func updateNavigationBar() {
        navigationItem.rightBarButtonItem?.customView?.isHidden = dataManager.isEmpty
    }
    
    // MARK: - Actions
    @objc private func clearAllButtonTapped() {
        navigationManager.showClearAllConfirmation { [weak self] in
            self?.clearAllHistory()
        }
    }
    
    private func clearAllHistory() {
        tableManager.animateTableViewUpdate { [weak self] in
            self?.dataManager.clearAllSessions()
            HapticFeedback.success()
        }
    }
    // MARK: - HistoryDataManagerDelegate
    func didUpdateChatSessions(_ sessions: [ChatSession]) {
        tableManager.updateSessions(sessions)
        updateEmptyState()
        updateNavigationBar()
    }
    
    func didDeleteSession(at index: Int) {
        tableManager.deleteSession(at: index)
        
        if dataManager.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.updateEmptyState()
                self.updateNavigationBar()
            }
        }
    }
    
    func didClearAllSessions() {
        updateEmptyState()
        updateNavigationBar()
    }
    
    // MARK: - HistoryTableManagerDelegate
    func didSelectSession(at index: Int) {
        guard let session = dataManager.getSession(at: index) else { return }
        navigationManager.navigateToChat(with: session)
    }
    
    func didRequestDeleteSession(at index: Int) {
        dataManager.deleteSession(at: index)
    }
}
