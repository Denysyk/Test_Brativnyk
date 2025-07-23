//
//  IPInfoCardView.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit
import CoreLocation

class IPInfoCardView: UIView {
    
    private struct InfoItem {
        let headerLabel: UILabel
        let valueLabel: UILabel
        let headerText: String
        
        init(headerText: String) {
            self.headerLabel = UILabel()
            self.valueLabel = UILabel()
            self.headerText = headerText
        }
    }
    
    private var infoItems: [InfoItem] = []
    private let spacing: CGFloat = 16
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.secondarySystemBackground
        layer.cornerRadius = 16
        layer.shadowColor = UIColor.label.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.1
        
        createInfoItems()
        setupLabels()
        setupConstraints()
    }
    
    private func createInfoItems() {
        let headerTexts = [
            NSLocalizedString("ip_address", comment: ""),
            NSLocalizedString("location", comment: ""),
            NSLocalizedString("region", comment: ""),
            NSLocalizedString("country", comment: ""),
            NSLocalizedString("timezone", comment: ""),
            NSLocalizedString("isp", comment: ""),
            NSLocalizedString("organization", comment: ""),
            NSLocalizedString("coordinates", comment: "")
        ]
        
        infoItems = headerTexts.map { InfoItem(headerText: $0) }
    }
    
    private func setupLabels() {
        for item in infoItems {
            setupHeaderLabel(item.headerLabel, text: item.headerText)
            setupValueLabel(item.valueLabel)
            
            addSubview(item.headerLabel)
            addSubview(item.valueLabel)
        }
    }
    
    private func setupHeaderLabel(_ label: UILabel, text: String) {
        label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        label.textColor = UIColor.secondaryLabel
        label.text = text
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupValueLabel(_ label: UILabel) {
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.label
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupConstraints() {
        var constraints: [NSLayoutConstraint] = []
        
        for (index, item) in infoItems.enumerated() {
            let topAnchor = index == 0 ? self.topAnchor : infoItems[index - 1].valueLabel.bottomAnchor
            let topConstant: CGFloat = index == 0 ? spacing : spacing
            
            constraints.append(contentsOf: [
                item.headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
                item.headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
                item.headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing),
                
                item.valueLabel.topAnchor.constraint(equalTo: item.headerLabel.bottomAnchor, constant: 4),
                item.valueLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: spacing),
                item.valueLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -spacing)
            ])
            
            if index == infoItems.count - 1 {
                constraints.append(
                    item.valueLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -spacing)
                )
            }
        }
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func configure(with ipInfo: IPInfo) {
        guard infoItems.count == 8 else { return }
        
        let values = [
            ipInfo.query,
            ipInfo.formattedLocation,
            "\(ipInfo.region) - \(ipInfo.regionName)",
            "\(LocalizationManager.shared.localizedCountryName(for: ipInfo.countryCode, fallback: ipInfo.country)) (\(ipInfo.countryCode))",
            ipInfo.timezone,
            ipInfo.isp,
            ipInfo.org,
            CLLocationCoordinate2D(latitude: ipInfo.lat, longitude: ipInfo.lon).formattedString
        ]
        
        for (index, value) in values.enumerated() {
            infoItems[index].valueLabel.text = value
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            layer.shadowColor = UIColor.label.cgColor
        }
    }
}
