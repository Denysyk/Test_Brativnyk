//
//  IPInfo.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

struct IPInfo: Codable {
    let query: String
    let status: String
    let country: String
    let countryCode: String
    let region: String
    let regionName: String
    let city: String
    let zip: String
    let lat: Double
    let lon: Double
    let timezone: String
    let isp: String
    let org: String
    let `as`: String
    
    // Computed properties для локалізованих значень
    var localizedCountry: String {
        return NSLocalizedString("country_\(countryCode.lowercased())",
                                value: country,
                                comment: "Country name")
    }
    
    var formattedLocation: String {
        return "\(city), \(regionName), \(country)"
    }
    
    var isValid: Bool {
        return status == "success"
    }
}
