//
//  IPInfoManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

protocol IPInfoManagerDelegate: AnyObject {
    func didStartLoading()
    func didReceiveIPInfo(_ ipInfo: IPInfo)
    func didFailWithError(_ error: NetworkError)
}

class IPInfoManager {
    weak var delegate: IPInfoManagerDelegate?
    private(set) var currentIPInfo: IPInfo?
    
    func loadIPInfo() {
        delegate?.didStartLoading()
        
        NetworkService.shared.fetchIPInfo { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let ipInfo):
                    self?.currentIPInfo = ipInfo
                    self?.delegate?.didReceiveIPInfo(ipInfo)
                case .failure(let error):
                    self?.delegate?.didFailWithError(error)
                }
            }
        }
    }
    
    func reloadIPInfo() {
        loadIPInfo()
    }
}
