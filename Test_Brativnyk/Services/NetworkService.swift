//
//  NetworkService.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation
import SystemConfiguration

enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError
    case networkError(Error)
    case invalidResponse
    case timeout
    
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
        case .invalidResponse:
            return NSLocalizedString("invalid_response_error", comment: "")
        case .timeout:
            return NSLocalizedString("timeout_error", comment: "")
        }
    }
}

class NetworkService {
    static let shared = NetworkService()
    
    private init() {}
    
    private let baseURL = "http://ip-api.com/json/"
    private let timeout: TimeInterval = 10.0
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2
        config.waitsForConnectivity = true
        config.allowsConstrainedNetworkAccess = true
        config.allowsExpensiveNetworkAccess = true
        
        return URLSession(configuration: config)
    }()
    
    func fetchIPInfo(completion: @escaping (Result<IPInfo, NetworkError>) -> Void) {
        performIPInfoRequest(urlString: baseURL, completion: completion)
    }
    
    func fetchIPInfo(for ip: String, completion: @escaping (Result<IPInfo, NetworkError>) -> Void) {
        let urlString = baseURL + ip.trimmingCharacters(in: .whitespacesAndNewlines)
        performIPInfoRequest(urlString: urlString, completion: completion)
    }
    
    private func performIPInfoRequest(urlString: String, completion: @escaping (Result<IPInfo, NetworkError>) -> Void) {
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion(.failure(.invalidURL))
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = timeout
        request.cachePolicy = .reloadIgnoringLocalCacheData
        
        // Додаємо headers для кращої сумісності
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("iOS-App", forHTTPHeaderField: "User-Agent")
        
        let task = session.dataTask(with: request) { [weak self] data, response, error in
            self?.handleResponse(data: data, response: response, error: error, completion: completion)
        }
        
        task.resume()
    }
    
    private func handleResponse(
        data: Data?,
        response: URLResponse?,
        error: Error?,
        completion: @escaping (Result<IPInfo, NetworkError>) -> Void
    ) {
        DispatchQueue.main.async {
            // Перевіряємо наявність помилки
            if let error = error {
                let networkError: NetworkError
                
                if (error as NSError).code == NSURLErrorTimedOut {
                    networkError = .timeout
                } else {
                    networkError = .networkError(error)
                }
                
                completion(.failure(networkError))
                return
            }
            
            // Перевіряємо HTTP статус
            if let httpResponse = response as? HTTPURLResponse {
                guard (200...299).contains(httpResponse.statusCode) else {
                    completion(.failure(.invalidResponse))
                    return
                }
            }
            
            // Перевіряємо наявність даних
            guard let data = data, !data.isEmpty else {
                completion(.failure(.noData))
                return
            }
            
            // Декодуємо JSON
            do {
                let ipInfo = try self.decodeIPInfo(from: data)
                
                // Перевіряємо валідність отриманих даних
                guard ipInfo.isValid else {
                    completion(.failure(.decodingError))
                    return
                }
                
                completion(.success(ipInfo))
                
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(.decodingError))
            }
        }
    }
    
    private func decodeIPInfo(from data: Data) throws -> IPInfo {
        let decoder = JSONDecoder()
        
        // Додаємо стратегію для невідомих ключів
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        return try decoder.decode(IPInfo.self, from: data)
    }
}

// MARK: - Network Monitoring
extension NetworkService {
    
    var isNetworkAvailable: Bool {
        // Простий спосіб перевірки доступності мережі
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    func cancelAllRequests() {
        session.invalidateAndCancel()
    }
}
