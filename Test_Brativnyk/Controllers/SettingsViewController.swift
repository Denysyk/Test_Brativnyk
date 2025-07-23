//
//  SettingsViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 18.07.2025.
//

import UIKit

class SettingsViewController: UIViewController, SettingsTableManagerDelegate, SettingsActionManagerDelegate {
    
    // MARK: - UI Elements
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    
    // MARK: - Managers
    private lazy var tableManager = SettingsTableManager(tableView: tableView)
    private let actionManager = SettingsActionManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupDelegates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemGroupedBackground
        title = NSLocalizedString("Settings", comment: "")
        
        setupTableView()
        setupConstraints()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
    }
    
    private func setupConstraints() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupDelegates() {
        tableManager.delegate = self
        actionManager.delegate = self
    }
    
    // MARK: - SettingsTableManagerDelegate
    func didSelectAction(_ action: SettingsAction) {
        view.endEditing(true)
        actionManager.performAction(action)
    }
    
    // MARK: - SettingsActionManagerDelegate
    func presentAlert(_ alert: UIAlertController) {
        present(alert, animated: true)
    }
    
    func presentActivityController(_ controller: UIActivityViewController) {
        if let popover = controller.popoverPresentationController {
            popover.sourceView = view
            popover.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        present(controller, animated: true)
    }
}
