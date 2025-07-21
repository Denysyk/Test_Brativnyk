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
    private let inputContainerView = UIView()
    private let textView = UITextView()
    private let sendButton = UIButton(type: .system)
    private let placeholderLabel = UILabel()
    private let emptyStateView = UIView()
    private let emptyStateImageView = UIImageView()
    private let emptyStateLabel = UILabel()
    
    // MARK: - Properties
    private var messages: [ChatMessage] = []
    private var chatId = "main_chat"
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    private var inputContainerHeightConstraint: NSLayoutConstraint!
    private var isTyping = false
    private let maxTextViewHeight: CGFloat = 120
    private let minTextViewHeight: CGFloat = 44
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        setupNavigationBar()
        loadMessages()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = NSLocalizedString("Chat", comment: "")
        
        // Table View
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.keyboardDismissMode = .interactive
        view.addSubview(tableView)
        
        // Input Container
        inputContainerView.backgroundColor = UIColor.clear
        view.addSubview(inputContainerView)
        
        // Text View
        textView.delegate = self
        textView.layer.cornerRadius = 20.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 50)
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.systemBackground
        textView.textContainer.lineFragmentPadding = 0
        textView.showsVerticalScrollIndicator = false
        inputContainerView.addSubview(textView)
        
        // Placeholder
        placeholderLabel.text = NSLocalizedString("Type a message...", comment: "")
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.font = UIFont.systemFont(ofSize: 16)
        textView.addSubview(placeholderLabel)
        
        // Send Button
        sendButton.setImage(UIImage(systemName: "paperplane.fill"), for: .normal)
        sendButton.tintColor = UIColor.systemGreen
        sendButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        sendButton.isEnabled = false
        sendButton.alpha = 0.5
        inputContainerView.addSubview(sendButton)
        
        // Empty State View
        setupEmptyStateView()
        view.addSubview(emptyStateView)
    }
    
    private func setupNavigationBar() {
        // Кнопка нового чату
        let newChatButton = UIButton(type: .system)
        
        // Створюємо конфігурацію для кнопки
        var config = UIButton.Configuration.borderless()
        config.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        // Додаємо тільки іконку
        config.image = UIImage(systemName: "square.and.pencil")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        )
        
        newChatButton.configuration = config
        newChatButton.addTarget(self, action: #selector(newChatButtonTapped), for: .touchUpInside)
        
        // Додаємо анімацію при натисканні
        newChatButton.addTarget(self, action: #selector(newChatButtonTouchDown), for: .touchDown)
        newChatButton.addTarget(self, action: #selector(newChatButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: newChatButton)
    }
    
    private func setupEmptyStateView() {
        emptyStateView.backgroundColor = .clear
        emptyStateView.isHidden = true
        
        // Image
        emptyStateImageView.image = UIImage(systemName: "message")
        emptyStateImageView.tintColor = UIColor.systemGray3
        emptyStateImageView.contentMode = .scaleAspectFit
        emptyStateView.addSubview(emptyStateImageView)
        
        // Label
        emptyStateLabel.text = NSLocalizedString("Start typing to begin conversation", comment: "")
        emptyStateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        emptyStateLabel.textColor = UIColor.systemGray2
        emptyStateLabel.textAlignment = .center
        emptyStateLabel.numberOfLines = 0
        emptyStateView.addSubview(emptyStateLabel)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        emptyStateView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyStateLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Input Container Bottom Constraint (буде змінюватися при появі клавіатури)
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
        
        // Input Container Height Constraint (буде змінюватися при зміні розміру тексту)
        inputContainerHeightConstraint = inputContainerView.heightAnchor.constraint(equalToConstant: minTextViewHeight)
        
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -8),
            
            // Input Container - така ж ширина як таб-бар
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputContainerBottomConstraint,
            inputContainerHeightConstraint,
            
            // Text View - займає всю ширину контейнера
            textView.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),
            
            // Send Button - поверх текстового поля
            sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            sendButton.trailingAnchor.constraint(equalTo: textView.trailingAnchor, constant: -12),
            sendButton.widthAnchor.constraint(equalToConstant: 32),
            sendButton.heightAnchor.constraint(equalToConstant: 32),
            
            // Placeholder
            placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 16),
            placeholderLabel.trailingAnchor.constraint(equalTo: sendButton.leadingAnchor, constant: -8),
            
            // Empty State View
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            emptyStateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            // Empty State Image
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 60),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 60),
            
            // Empty State Label
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
            emptyStateLabel.bottomAnchor.constraint(equalTo: emptyStateView.bottomAnchor)
        ])
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    
    // MARK: - Data Methods
    private func loadMessages() {
        messages = CoreDataManager.shared.getChatMessages(chatId: chatId)
        tableView.reloadData()
        updateEmptyState()
        scrollToBottom()
    }
    
    private func updateEmptyState() {
        let isEmpty = messages.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func addMessage(_ message: ChatMessage) {
        messages.append(message)
        
        // Зберігаємо повідомлення - це автоматично оновить updatedAt чату
        CoreDataManager.shared.saveMessage(message, chatId: chatId)
        
        DispatchQueue.main.async {
            // Безпечне оновлення таблиці
            let wasEmpty = self.messages.count == 1
            
            if wasEmpty {
                self.updateEmptyState()
                self.tableView.reloadData()
            } else {
                self.tableView.performBatchUpdates({
                    let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
                    self.tableView.insertRows(at: [indexPath], with: .bottom)
                }, completion: { _ in
                    self.scrollToBottomSafely()
                })
            }
        }
    }
    
    private func scrollToBottom() {
        guard !messages.isEmpty else { return }
        
        DispatchQueue.main.async {
            // Додаткові перевірки для уникнення NaN
            guard self.tableView.numberOfSections > 0 else { return }
            let numberOfRows = self.tableView.numberOfRows(inSection: 0)
            guard numberOfRows > 0, numberOfRows == self.messages.count else { return }
            
            let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
            
            // Перевіряємо чи існує ця комірка
            guard self.tableView.cellForRow(at: indexPath) != nil || numberOfRows <= 1 else {
                // Якщо комірка не існує, спробуємо через невелику затримку
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToBottomSafely()
                }
                return
            }
            
            self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    private func scrollToBottomSafely() {
        guard !messages.isEmpty,
              tableView.numberOfSections > 0,
              tableView.numberOfRows(inSection: 0) == messages.count else { return }
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func createNewChat() {
        // Генеруємо новий ID для чату
        chatId = UUID().uuidString
        
        // Очищуємо поточні повідомлення
        messages.removeAll()
        tableView.reloadData()
        updateEmptyState()
        
        // Очищуємо поле вводу
        textView.text = ""
        textViewDidChange(textView)
        resetTextViewHeight()
        
        // Прибираємо кнопку повернення, якщо вона є
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        // Додаємо повідомлення користувача
        let userMessage = ChatMessage(text: text, type: .user)
        addMessage(userMessage)
        
        // Очищуємо поле вводу
        textView.text = ""
        textViewDidChange(textView)
        
        // Додаємо анімацію "друкування"
        showTypingIndicator()
        
        // Генеруємо відповідь бота з затримкою
        ChatService.shared.generateBotResponseWithDelay { [weak self] response in
            self?.hideTypingIndicator()
            let botMessage = ChatMessage(text: response, type: .bot)
            self?.addMessage(botMessage)
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func newChatButtonTapped() {
        // Показуємо алерт підтвердження, якщо є повідомлення
        if !messages.isEmpty {
            let alert = UIAlertController(
                title: NSLocalizedString("New Chat", comment: ""),
                message: NSLocalizedString("Start a new conversation? Current chat will be saved.", comment: ""),
                preferredStyle: .alert
            )
            
            alert.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel))
            alert.addAction(UIAlertAction(title: NSLocalizedString("New Chat", comment: ""), style: .default) { _ in
                self.createNewChat()
            })
            
            present(alert, animated: true)
        } else {
            createNewChat()
        }
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    @objc private func newChatButtonTouchDown() {
        guard let button = navigationItem.rightBarButtonItem?.customView else { return }
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func newChatButtonTouchUp() {
        guard let button = navigationItem.rightBarButtonItem?.customView else { return }
        UIView.animate(withDuration: 0.1) {
            button.transform = .identity
        }
    }
    
    private func showTypingIndicator() {
        isTyping = true
        // Тут можна додати індикатор "друкування"
    }
    
    private func hideTypingIndicator() {
        isTyping = false
        // Прибираємо індикатор "друкування"
    }
    
    // MARK: - Public Methods
    func loadChatWithId(_ id: String) {
        chatId = id
        loadMessages()
        
        // ВАЖЛИВО: Оновлюємо дату останнього доступу до чату
        CoreDataManager.shared.updateChatSessionAccess(chatId: id)
        
        // Скидаємо розмір поля вводу
        resetTextViewHeight()
        
        // Додаємо кнопку повернення назад
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backToHistoryTapped)
        )
        backButton.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        navigationItem.leftBarButtonItem = backButton
        
        // Очищуємо поле вводу
        textView.text = ""
        textViewDidChange(textView)
        resetTextViewHeight()
    }
    
    @objc private func backToHistoryTapped() {
        // Повертаємося до історії
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.selectedIndex = 2 // Індекс History табу
        }
        
        // Прибираємо кнопку повернення
        navigationItem.leftBarButtonItem = nil
        
        // Очищуємо поточний chatId, щоб повернутися до головного чату
        chatId = "main_chat"
        loadMessages()
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        inputContainerBottomConstraint.constant = -keyboardHeight - 20 + view.safeAreaInsets.bottom // Додаємо 20px відступ до клавіатури
        
        // Приховуємо кастомний таб-бар
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.hideCustomTabBar()
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
        
        scrollToBottom()
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        inputContainerBottomConstraint.constant = -100 // Повертаємо відступ для таб-бару
        
        // Показуємо кастомний таб-бар назад
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.showCustomTabBar()
        }
        
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            // Оновлюємо кольори при зміні теми
            textView.layer.borderColor = UIColor.systemGray4.cgColor
            textView.backgroundColor = UIColor.systemBackground
            
            // Оновлюємо кольор кнопки нового чату
            if let button = navigationItem.rightBarButtonItem?.customView as? UIButton {
                var config = button.configuration
                config?.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
                button.configuration = config
            }
            
            // Оновлюємо кольор кнопки назад
            if let backButton = navigationItem.leftBarButtonItem {
                backButton.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
            }
            
            DispatchQueue.main.async {
                self.view.setNeedsLayout()
                self.view.layoutIfNeeded()
            }
        }
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

// MARK: - UITextViewDelegate
extension ChatViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        placeholderLabel.isHidden = !textView.text.isEmpty
        
        let hasText = !textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        sendButton.isEnabled = hasText
        sendButton.alpha = hasText ? 1.0 : 0.5
        
        // Автоматичне зміна розміру text view
        updateTextViewHeight()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
    
    private func updateTextViewHeight() {
        // Обчислюємо потрібну висоту для тексту
        let fixedWidth = textView.frame.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        
        // Обмежуємо висоту між мінімумом та максимумом
        let newHeight = max(minTextViewHeight, min(maxTextViewHeight, newSize.height))
        
        // Оновлюємо constraint тільки якщо висота змінилася
        if inputContainerHeightConstraint.constant != newHeight {
            inputContainerHeightConstraint.constant = newHeight
            
            // Увімкнемо прокрутку, якщо досягли максимальної висоти
            textView.isScrollEnabled = newHeight >= maxTextViewHeight
            
            // Анімуємо зміну
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.view.layoutIfNeeded()
            }
            
            // Прокручуємо до низу таблиці при розширенні
            if !messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToBottomSafely()
                }
            }
        }
    }
    
    private func resetTextViewHeight() {
        inputContainerHeightConstraint.constant = minTextViewHeight
        textView.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}
