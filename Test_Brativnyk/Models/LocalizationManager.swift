//
//  LocalizationManager.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    // MARK: - Current Language
    var currentLanguage: String {
        return Bundle.main.preferredLocalizations.first ?? "en"
    }
    
    var isGerman: Bool {
        return currentLanguage.hasPrefix("de")
    }
    
    var isEnglish: Bool {
        return currentLanguage.hasPrefix("en")
    }
    
    // MARK: - Localized Strings
    func localizedString(for key: String, comment: String = "") -> String {
        return NSLocalizedString(key, comment: comment)
    }
    
    // MARK: - Common Strings
    struct Common {
        static var loading: String {
            return NSLocalizedString("loading", value: "Loading...", comment: "")
        }
        
        static var error: String {
            return NSLocalizedString("error", value: "Error", comment: "")
        }
        
        static var retry: String {
            return NSLocalizedString("retry", value: "Retry", comment: "")
        }
        
        static var cancel: String {
            return NSLocalizedString("cancel", value: "Cancel", comment: "")
        }
        
        static var ok: String {
            return NSLocalizedString("ok", value: "OK", comment: "")
        }
        
        static var delete: String {
            return NSLocalizedString("delete", value: "Delete", comment: "")
        }
        
        static var save: String {
            return NSLocalizedString("save", value: "Save", comment: "")
        }
    }
    
    // MARK: - Tab Bar
    struct TabBar {
        static var chat: String {
            return NSLocalizedString("Chat", comment: "")
        }
        
        static var ipInfo: String {
            return NSLocalizedString("IP Info", comment: "")
        }
        
        static var history: String {
            return NSLocalizedString("History", comment: "")
        }
        
        static var settings: String {
            return NSLocalizedString("Settings", comment: "")
        }
    }
    
    // MARK: - IP Info
    struct IPInfo {
        static var title: String {
            return NSLocalizedString("IP Info", comment: "")
        }
        
        static var ipAddress: String {
            return NSLocalizedString("ip_address", comment: "")
        }
        
        static var location: String {
            return NSLocalizedString("location", comment: "")
        }
        
        static var region: String {
            return NSLocalizedString("region", comment: "")
        }
        
        static var country: String {
            return NSLocalizedString("country", comment: "")
        }
        
        static var timezone: String {
            return NSLocalizedString("timezone", comment: "")
        }
        
        static var isp: String {
            return NSLocalizedString("isp", comment: "")
        }
        
        static var organization: String {
            return NSLocalizedString("organization", comment: "")
        }
        
        static var coordinates: String {
            return NSLocalizedString("coordinates", comment: "")
        }
        
        static var loading: String {
            return NSLocalizedString("loading_ip_info", comment: "")
        }
        
        static var loadingError: String {
            return NSLocalizedString("failed_to_load_ip_info", comment: "")
        }
        
        static var reload: String {
            return NSLocalizedString("reload", comment: "")
        }
    }
    
    // MARK: - Date Formatting
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: currentLanguage)
        return formatter
    }()
    
    private lazy var timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: currentLanguage)
        return formatter
    }()
    
    private lazy var relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: currentLanguage)
        formatter.unitsStyle = .full
        return formatter
    }()
    
    func formatDate(_ date: Date, style: DateFormatter.Style = .medium) -> String {
        dateFormatter.dateStyle = style
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
    
    func formatTime(_ date: Date) -> String {
        return timeFormatter.string(from: date)
    }
    
    func formatRelativeDate(_ date: Date) -> String {
        let calendar = Calendar.current
        let now = Date()
        
        if calendar.isDate(date, inSameDayAs: now) {
            return NSLocalizedString("Today", comment: "")
        } else if calendar.isDate(date, inSameDayAs: calendar.date(byAdding: .day, value: -1, to: now) ?? now) {
            return NSLocalizedString("Yesterday", comment: "")
        } else if calendar.dateInterval(of: .weekOfYear, for: now)?.contains(date) == true {
            dateFormatter.dateFormat = "EEEE"
            return dateFormatter.string(from: date)
        } else {
            return formatDate(date, style: .short)
        }
    }
    
    // MARK: - Number Formatting
    private lazy var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: currentLanguage)
        return formatter
    }()
    
    func formatCoordinates(latitude: Double, longitude: Double) -> String {
        let latDirection = latitude >= 0 ? "N" : "S"
        let lonDirection = longitude >= 0 ? "E" : "W"
        
        return String(format: "%.6f°%@ %.6f°%@",
                     abs(latitude), latDirection,
                     abs(longitude), lonDirection)
    }
    
    // MARK: - Country Name Localization
    func localizedCountryName(for countryCode: String, fallback: String) -> String {
        let key = "country_\(countryCode.lowercased())"
        let localized = NSLocalizedString(key, value: fallback, comment: "Country name")
        
        // If localization is not found, return the fallback
        return localized != key ? localized : fallback
    }
}
