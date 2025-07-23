//
//  SettingsTableManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol SettingsTableManagerDelegate: AnyObject {
    func didSelectAction(_ action: SettingsAction)
}

class SettingsTableManager: NSObject {
    weak var delegate: SettingsTableManagerDelegate?
    private weak var tableView: UITableView?
    private let dataManager = SettingsDataManager()
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.backgroundColor = .clear
        tableView?.separatorStyle = .singleLine
        tableView?.separatorInset = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        tableView?.rowHeight = 60
        tableView?.sectionHeaderHeight = 40
        tableView?.sectionFooterHeight = 20
        tableView?.register(SettingsTableViewCell.self, forCellReuseIdentifier: SettingsTableViewCell.identifier)
    }
}

// MARK: - UITableViewDataSource
extension SettingsTableManager: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataManager.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SettingsTableViewCell.identifier, for: indexPath) as! SettingsTableViewCell
        
        if let item = dataManager.getItem(at: indexPath.row) {
            cell.configure(with: item)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return NSLocalizedString("App Settings", comment: "")
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return NSLocalizedString("Version", comment: "") + " \(dataManager.appVersion)"
    }
}

// MARK: - UITableViewDelegate
extension SettingsTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let item = dataManager.getItem(at: indexPath.row) else { return }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.delegate?.didSelectAction(item.action)
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
