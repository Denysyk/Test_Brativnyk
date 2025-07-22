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
    private var chatId: String?
    private var inputContainerBottomConstraint: NSLayoutConstraint!
    private var inputContainerHeightConstraint: NSLayoutConstraint!
    private var isTyping = false
    private var maxTextViewHeight: CGFloat = 120.0
    private var minTextViewHeight: CGFloat = 44.0
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeSafeConstants()
        setupUI()
        setupConstraints()
        setupKeyboardObservers()
        setupNavigationBar()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.loadInitialChatState()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        cleanupInputSessions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !messages.isEmpty {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.scrollToBottomWithoutAnimation()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if self.textView.frame.width <= 0 || !self.textView.frame.width.isFinite {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            if self.textView.frame.width <= 0 ||
               !self.textView.frame.width.isFinite ||
               self.textView.frame.width.isNaN {
                
                let containerWidth = self.inputContainerView.frame.width
                if containerWidth > 0 && containerWidth.isFinite && !containerWidth.isNaN {
                    self.textView.frame = CGRect(
                        x: 0,
                        y: 0,
                        width: containerWidth,
                        height: self.minTextViewHeight
                    )
                }
            }
        }
    }
    
    // MARK: - Input Session Cleanup
    func cleanupInputSessions() {
        // Forcefully end editing
        view.endEditing(true)
        textView.resignFirstResponder()
        
        // Extra safety measure
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.textView.inputView = nil
            self.textView.inputAccessoryView = nil
        }
    }
    
    // MARK: - Safe Constants Initialization
    private func initializeSafeConstants() {
        let safeMin: CGFloat = 44.0
        let safeMax: CGFloat = 120.0
        
        guard safeMin.isFinite, !safeMin.isNaN, safeMin > 0,
              safeMax.isFinite, !safeMax.isNaN, safeMax > safeMin else {
            fatalError("Invalid text view height constants")
        }
        
        self.minTextViewHeight = safeMin
        self.maxTextViewHeight = safeMax
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
        setupTextViewSafely()
        
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
    
    private func setupTextViewSafely() {
        textView.delegate = self
        textView.frame = CGRect(x: 0, y: 0, width: 300, height: minTextViewHeight)
        textView.layer.cornerRadius = 20.0
        textView.layer.borderWidth = 1.0
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.font = UIFont.systemFont(ofSize: 16)
        
        // Configure text container
        textView.textContainer.lineFragmentPadding = 0.0
        textView.textContainer.maximumNumberOfLines = 0
        textView.textContainer.lineBreakMode = .byWordWrapping
        
        // Set text container insets
        let safeInset = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 10.0, right: 50.0)
        textView.textContainerInset = safeInset
        textView.isScrollEnabled = false
        textView.backgroundColor = UIColor.systemBackground
        textView.showsVerticalScrollIndicator = false
        
        // Disable problematic iOS features
        textView.autocorrectionType = .no
        textView.spellCheckingType = .no
        textView.smartQuotesType = .no
        textView.smartDashesType = .no
        textView.smartInsertDeleteType = .no
        textView.contentMode = .topLeft
        
        inputContainerView.addSubview(textView)
    }
    
    private func setupNavigationBar() {
        let newChatButton = UIButton(type: .system)
        
        var config = UIButton.Configuration.borderless()
        config.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        config.image = UIImage(systemName: "square.and.pencil")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        )
        
        newChatButton.configuration = config
        newChatButton.addTarget(self, action: #selector(newChatButtonTapped), for: .touchUpInside)
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
        
        let safeBottomConstant: CGFloat = -100.0
        
        guard safeBottomConstant.isFinite, !safeBottomConstant.isNaN else {
            return
        }
        
        inputContainerBottomConstraint = inputContainerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: safeBottomConstant)
        inputContainerHeightConstraint = inputContainerView.heightAnchor.constraint(equalToConstant: minTextViewHeight)
        
        NSLayoutConstraint.activate([
            // Table View
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: inputContainerView.topAnchor, constant: -8),
            
            // Input Container
            inputContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            inputContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            inputContainerBottomConstraint,
            inputContainerHeightConstraint,
            
            // Text View
            textView.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            textView.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),
            
            // Send Button
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
    private func loadInitialChatState() {
        let lastChatSession = CoreDataManager.shared.getLastChatSession()
        
        if let lastSession = lastChatSession, let sessionId = lastSession.id {
            chatId = sessionId
            loadMessages()
        } else {
            chatId = nil
            messages = []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateEmptyState()
            }
        }
        
        navigationItem.leftBarButtonItem = nil
        textView.text = ""
        textViewDidChange(textView)
        setInitialTextViewHeight()
    }
    
    private func loadMessages() {
        guard let chatId = chatId else {
            messages = []
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.updateEmptyState()
            }
            return
        }
        
        messages = CoreDataManager.shared.getChatMessages(chatId: chatId)
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
        }
    }
    
    private func updateEmptyState() {
        let isEmpty = messages.isEmpty
        emptyStateView.isHidden = !isEmpty
        tableView.isHidden = isEmpty
    }
    
    private func addMessage(_ message: ChatMessage) {
        if chatId == nil {
            chatId = UUID().uuidString
        }
        
        guard let currentChatId = chatId else { return }
        
        messages.append(message)
        CoreDataManager.shared.saveMessage(message, chatId: currentChatId)
        
        DispatchQueue.main.async {
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
        guard !messages.isEmpty,
              view.window != nil,
              tableView.superview != nil else { return }
        
        DispatchQueue.main.async {
            guard self.tableView.numberOfSections > 0 else { return }
            let numberOfRows = self.tableView.numberOfRows(inSection: 0)
            guard numberOfRows > 0, numberOfRows == self.messages.count else { return }
            
            let indexPath = IndexPath(row: numberOfRows - 1, section: 0)
            
            if numberOfRows <= 1 || self.tableView.cellForRow(at: indexPath) != nil {
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToBottomSafely()
                }
            }
        }
    }
    
    private func scrollToBottomWithoutAnimation() {
        guard !messages.isEmpty,
              view.window != nil,
              tableView.superview != nil,
              tableView.numberOfSections > 0,
              tableView.numberOfRows(inSection: 0) == messages.count else { return }
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
    }
    
    private func scrollToBottomSafely() {
        guard !messages.isEmpty,
              view.window != nil,
              tableView.superview != nil,
              tableView.numberOfSections > 0,
              tableView.numberOfRows(inSection: 0) == messages.count else { return }
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    private func createNewChat() {
        cleanupInputSessions()
        chatId = nil
        messages.removeAll()
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
        }
        
        textView.text = ""
        textViewDidChange(textView)
        setInitialTextViewHeight()
        navigationItem.leftBarButtonItem = nil
    }
    
    // MARK: - Safe Text Height Calculation
    private func calculateTextHeight(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        guard !text.isEmpty,
              width > 0,
              width.isFinite,
              !width.isNaN else {
            return font.lineHeight
        }
        
        let nsString = text as NSString
        let textRect = nsString.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: font],
            context: nil
        )
        
        guard textRect.height.isFinite,
              !textRect.height.isNaN,
              textRect.height > 0 else {
            return font.lineHeight
        }
        
        return max(font.lineHeight, textRect.height)
    }
    
    // MARK: - updateTextViewHeight Method
    private func updateTextViewHeight() {
        guard let superview = textView.superview,
              superview.frame.width > 0,
              superview.frame.width.isFinite,
              !superview.frame.width.isNaN else {
            return
        }
        
        let containerWidth = superview.frame.width
        let textInsets = textView.textContainerInset
        
        guard textInsets.left.isFinite && !textInsets.left.isNaN,
              textInsets.right.isFinite && !textInsets.right.isNaN else {
            return
        }
        
        let availableWidth = containerWidth - textInsets.left - textInsets.right
        
        guard availableWidth > 20,
              availableWidth.isFinite,
              !availableWidth.isNaN else {
            return
        }
        
        let textHeight = calculateTextHeight(
            text: textView.text,
            width: availableWidth,
            font: textView.font ?? UIFont.systemFont(ofSize: 16)
        )
        
        guard textHeight.isFinite,
              !textHeight.isNaN,
              textHeight > 0 else {
            return
        }
        
        let totalHeight = textHeight + textInsets.top + textInsets.bottom
        let newHeight = max(minTextViewHeight, min(maxTextViewHeight, totalHeight))
        
        guard newHeight.isFinite,
              !newHeight.isNaN,
              newHeight > 0 else {
            return
        }
        
        if abs(inputContainerHeightConstraint.constant - newHeight) > 2.0 {
            inputContainerHeightConstraint.constant = newHeight
            textView.isScrollEnabled = newHeight >= maxTextViewHeight
            
            guard self.view.window != nil else { return }
            
            UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [.allowUserInteraction]) {
                self.view.layoutIfNeeded()
            }
            
            if !messages.isEmpty {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.scrollToBottomSafely()
                }
            }
        }
    }
    
    // MARK: - Text View Height Management
    private func setInitialTextViewHeight() {
        guard minTextViewHeight.isFinite,
              !minTextViewHeight.isNaN,
              minTextViewHeight > 0 else {
            return
        }
        
        inputContainerHeightConstraint.constant = minTextViewHeight
        textView.isScrollEnabled = false
    }
    
    private func resetTextViewHeight() {
        guard minTextViewHeight.isFinite,
              !minTextViewHeight.isNaN,
              minTextViewHeight > 0,
              self.view.window != nil else {
            return
        }
        
        inputContainerHeightConstraint.constant = minTextViewHeight
        textView.isScrollEnabled = false
        
        UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Actions
    @objc private func sendButtonTapped() {
        guard let text = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !text.isEmpty else { return }
        
        let userMessage = ChatMessage(text: text, type: .user)
        addMessage(userMessage)
        
        textView.text = ""
        textViewDidChange(textView)
        
        showTypingIndicator()
        
        ChatService.shared.generateBotResponseWithDelay { [weak self] response in
            self?.hideTypingIndicator()
            let botMessage = ChatMessage(text: response, type: .bot)
            self?.addMessage(botMessage)
        }
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func newChatButtonTapped() {
        cleanupInputSessions()
        
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
    }
    
    private func hideTypingIndicator() {
        isTyping = false
    }
    
    // MARK: - Public Methods
    func loadChatWithId(_ id: String) {
        cleanupInputSessions()
        chatId = id
        loadMessages()
        
        let backButton = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backToHistoryTapped)
        )
        backButton.tintColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        navigationItem.leftBarButtonItem = backButton
        
        textView.text = ""
        textViewDidChange(textView)
        resetTextViewHeight()
    }
    
    @objc private func backToHistoryTapped() {
        cleanupInputSessions()
        
        if let tabBarController = tabBarController as? TabBarController {
            tabBarController.selectedIndex = 2
        }
        
        navigationItem.leftBarButtonItem = nil
        loadInitialChatState()
    }
    
    // MARK: - Keyboard Handling
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let animationDuration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        inputContainerBottomConstraint.constant = -keyboardHeight - 20 + view.safeAreaInsets.bottom
        
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
        
        inputContainerBottomConstraint.constant = -100
        
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
            textView.layer.borderColor = UIColor.systemGray4.cgColor
            textView.backgroundColor = UIColor.systemBackground
            
            if let button = navigationItem.rightBarButtonItem?.customView as? UIButton {
                var config = button.configuration
                config?.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
                button.configuration = config
            }
            
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.updateTextViewHeight()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            sendButtonTapped()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateTextViewHeight()
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.updateTextViewHeight()
        }
    }
}
