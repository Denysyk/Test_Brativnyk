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
    
    // MARK: - Computed properties 
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
    
    // MARK: - Display Methods
    var displayLocation: String {
        let components = [city, regionName, country].filter { !$0.isEmpty }
        return components.joined(separator: ", ")
    }
    
    var displayRegion: String {
        if region.isEmpty && regionName.isEmpty {
            return NSLocalizedString("Unknown Region", comment: "")
        }
        return "\(region) - \(regionName)"
    }
    
    var displayCountry: String {
        let localizedName = LocalizationManager.shared.localizedCountryName(
            for: countryCode,
            fallback: country
        )
        return "\(localizedName) (\(countryCode))"
    }
    
    var displayCoordinates: String {
        return LocalizationManager.shared.formatCoordinates(
            latitude: lat,
            longitude: lon
        )
    }
    
    // MARK: - Validation
    var hasValidCoordinates: Bool {
        return abs(lat) <= 90.0 && abs(lon) <= 180.0 &&
               lat.isFinite && lon.isFinite &&
               !lat.isNaN && !lon.isNaN
    }
}
