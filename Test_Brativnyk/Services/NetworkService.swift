//
//  NetworkService.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return NSLocalizedString("invalid_url_error", comment: "")
        case .noData:
            return NSLocalizedString("no_data_error", comment: "")
        case .decodingError:
            return NSLocalizedString("decoding_error", comment: "")
        case .networkError(let error):
            return error.localizedDescription
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private let baseURL = "http://ip-api.com/json/"
    
    func fetchIPInfo(completion: @escaping (Result<IPInfo, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let ipInfo = try JSONDecoder().decode(IPInfo.self, from: data)
                    completion(.success(ipInfo))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            }
        }
        
        task.resume()
    }
    
    func fetchIPInfo(for ip: String, completion: @escaping (Result<IPInfo, NetworkError>) -> Void) {
        guard let url = URL(string: baseURL + ip) else {
            completion(.failure(.invalidURL))
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(.networkError(error)))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(.noData))
                    return
                }
                
                do {
                    let ipInfo = try JSONDecoder().decode(IPInfo.self, from: data)
                    completion(.success(ipInfo))
                } catch {
                    print("Decoding error: \(error)")
                    completion(.failure(.decodingError))
                }
            }
        }
        
        task.resume()
    }
}
