//
//  ChatViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: - UI Elements
    private let tableView = UITableView()
    private let inputManager = ChatInputManager()
    private let emptyStateView = EmptyStateView()
    
    // MARK: - Properties
    private var messages: [ChatMessage] = []
    private var chatId: String?
    private var hasAppeared = false
    
    // MARK: - Managers
    private let keyboardManager = KeyboardManager()
    private let chatDataManager = ChatDataManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardHandling()
        setupNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !hasAppeared {
            hasAppeared = true
            loadInitialChatState()
        }
        
        scrollToBottomIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
    }
    
    deinit {
        keyboardManager.cleanup()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = LocalizationManager.TabBar.chat
        
        setupTableView()
        setupInputManager()
        setupEmptyState()
        setupConstraints()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        view.addSubview(tableView)
    }
    
    private func setupInputManager() {
        inputManager.delegate = self
        view.addSubview(inputManager.containerView)
    }
    
    private func setupEmptyState() {
        emptyStateView.configure(
            image: "message",
            title: NSLocalizedString("Start typing to begin conversation", comment: "")
        )
        view.addSubview(emptyStateView)
    }
    
    private func setupConstraints() {
        [tableView, emptyStateView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputManager.containerView.topAnchor, constant: -8),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
        
        inputManager.setupConstraints(in: view)
    }
    
    private func setupKeyboardHandling() {
        keyboardManager.delegate = self
        keyboardManager.setup()
    }
    
    private func setupNavigationBar() {
        let newChatButton = UIButton.createNavigationButton(
            image: "square.and.pencil",
            target: self,
            action: #selector(newChatButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newChatButton)
    }
    
    // MARK: - Data Methods
    private func loadInitialChatState() {
        if let lastChatId = chatDataManager.getLastChatId() {
            chatId = lastChatId
            loadMessages()
        } else {
            chatId = nil
            messages = []
            updateUI()
        }
        
        navigationItem.leftBarButtonItem = nil
        inputManager.clearText()
    }
    
    private func loadMessages() {
        guard let chatId = chatId else {
            messages = []
            updateUI()
            return
        }
        
        messages = chatDataManager.loadMessages(for: chatId)
        updateUI()
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
            self.scrollToBottomIfNeeded()
        }
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !messages.isEmpty
        tableView.isHidden = messages.isEmpty
    }
    
    private func addMessage(_ message: ChatMessage) {
        if chatId == nil {
            chatId = UUID().uuidString
        }
        
        guard let currentChatId = chatId else { return }
        
        messages.append(message)
        chatDataManager.saveMessage(message, chatId: currentChatId)
        
        updateTableView(wasEmpty: messages.count == 1)
    }
    
    private func updateTableView(wasEmpty: Bool) {
        DispatchQueue.main.async {
            if wasEmpty {
                self.updateUI()
            } else {
                let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.insertRows(at: [indexPath], with: .bottom)
                self.scrollToBottom()
            }
        }
    }
    
    private func scrollToBottomIfNeeded() {
        guard !messages.isEmpty else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.scrollToBottom()
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty,
              tableView.numberOfRows(inSection: 0) == messages.count else { return }
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func createNewChat() {
        view.endEditing(true)
        
        if !messages.isEmpty {
            showNewChatConfirmation()
        } else {
            resetChat()
        }
    }
    
    private func showNewChatConfirmation() {
        let alert = UIAlertController(
            title: NSLocalizedString("New Chat", comment: ""),
            message: NSLocalizedString("Start a new conversation? Current chat will be saved.", comment: ""),
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
        alert.addAction(UIAlertAction(title: NSLocalizedString("New Chat", comment: ""), style: .default) { _ in
            self.resetChat()
        })
        
        present(alert, animated: true)
    }
    
    private func resetChat() {
        chatId = nil
        messages.removeAll()
        updateUI()
        inputManager.clearText()
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Actions
    @objc private func newChatButtonTapped() {
        createNewChat()
        HapticFeedback.impact(.medium)
    }
    
    // MARK: - Public Methods
    func loadChatWithId(_ id: String) {
        view.endEditing(true)
        chatId = id
        loadMessages()
        
        setupBackButton()
        inputManager.clearText()
    }
    
    private func setupBackButton() {
        let backButton = UIButton.createNavigationButton(
            image: "chevron.left",
            target: self,
            action: #selector(backToHistoryTapped)
        )
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    @objc private func backToHistoryTapped() {
        view.endEditing(true)
        
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.selectedIndex = TabBarItem.historyIndex
        }
        
        navigationItem.leftBarButtonItem = nil
        loadInitialChatState()
    }
}

// MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.identifier, for: indexPath) as! ChatMessageCell
        cell.configure(with: messages[indexPath.row])
        return cell
    }
}

// MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
    }
}

// MARK: - ChatInputManagerDelegate
extension ChatViewController: ChatInputManagerDelegate {
    func didSendMessage(_ text: String) {
        let userMessage = ChatMessage(text: text, type: .user)
        addMessage(userMessage)
        
        ChatService.shared.generateBotResponseWithDelay { [weak self] response in
            let botMessage = ChatMessage(text: response, type: .bot)
            self?.addMessage(botMessage)
        }
        
        HapticFeedback.impact(.light)
    }
}

// MARK: - KeyboardManagerDelegate
// MARK: - KeyboardManagerDelegate
extension ChatViewController: KeyboardManagerDelegate {
    func keyboardWillShow(height: CGFloat, duration: TimeInterval) {
        inputManager.adjustForKeyboard(height: height, duration: duration)
        hideTabBar()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.scrollToBottom()
        }
    }
    
    func keyboardWillHide(duration: TimeInterval) {
        inputManager.adjustForKeyboard(height: 0, duration: duration)
        showTabBar()
    }
    
    private func hideTabBar() {
        (tabBarController as? TabBarController)?.hideCustomTabBar()
    }
    
    private func showTabBar() {
        (tabBarController as? TabBarController)?.showCustomTabBar()
    }
}
  
