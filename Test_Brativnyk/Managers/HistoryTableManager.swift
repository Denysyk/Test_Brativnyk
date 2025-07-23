//
//  HistoryTableManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

protocol HistoryTableManagerDelegate: AnyObject {
    func didSelectSession(at index: Int)
    func didRequestDeleteSession(at index: Int)
}

class HistoryTableManager: NSObject {
    weak var delegate: HistoryTableManagerDelegate?
    private weak var tableView: UITableView?
    private var chatSessions: [ChatSession] = []
    
    init(tableView: UITableView) {
        self.tableView = tableView
        super.init()
        setupTableView()
    }
    
    private func setupTableView() {
        tableView?.delegate = self
        tableView?.dataSource = self
        tableView?.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.identifier)
        tableView?.separatorStyle = .none
        tableView?.backgroundColor = .clear
        tableView?.showsVerticalScrollIndicator = false
    }
    
    func updateSessions(_ sessions: [ChatSession]) {
        chatSessions = sessions
        tableView?.reloadData()
    }
    
    func deleteSession(at index: Int) {
        guard index < chatSessions.count else { return }
        
        chatSessions.remove(at: index)
        tableView?.deleteRows(at: [IndexPath(row: index, section: 0)], with: .fade)
    }
    
    func animateTableViewUpdate(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.3) {
            self.tableView?.alpha = 0
        } completion: { _ in
            self.tableView?.reloadData()
            completion()
            
            UIView.animate(withDuration: 0.3) {
                self.tableView?.alpha = 1
            }
        }
    }
}

// MARK: - UITableViewDataSource
extension HistoryTableManager: UITableViewDataSource {
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
            delegate?.didRequestDeleteSession(at: indexPath.row)
        }
    }
}

// MARK: - UITableViewDelegate
extension HistoryTableManager: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectSession(at: indexPath.row)
        HapticFeedback.impact(.light)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: NSLocalizedString("Delete", comment: "")) { [weak self] _, _, completion in
            self?.delegate?.didRequestDeleteSession(at: indexPath.row)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        configuration.performsFirstActionWithFullSwipe = true
        
        return configuration
    }
}
