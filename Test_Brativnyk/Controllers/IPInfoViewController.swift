//
//  IPInfoViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit
import MapKit
import CoreLocation

class IPInfoViewController: UIViewController {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let infoContainerView = UIView()
    private let loadingView = UIView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    private let loadingLabel = UILabel()
    private let errorView = UIView()
    private let errorImageView = UIImageView()
    private let errorLabel = UILabel()
    private let retryButton = UIButton(type: .system)

    // Info Labels
    private let ipLabel = UILabel()
    private let locationLabel = UILabel()
    private let regionLabel = UILabel()
    private let countryLabel = UILabel()
    private let timezoneLabel = UILabel()
    private let ispLabel = UILabel()
    private let organizationLabel = UILabel()
    private let coordinatesLabel = UILabel()

    // Info Headers
    private let ipHeaderLabel = UILabel()
    private let locationHeaderLabel = UILabel()
    private let regionHeaderLabel = UILabel()
    private let countryHeaderLabel = UILabel()
    private let timezoneHeaderLabel = UILabel()
    private let ispHeaderLabel = UILabel()
    private let organizationHeaderLabel = UILabel()
    private let coordinatesHeaderLabel = UILabel()

    // MARK: - Properties
    private var currentIPInfo: IPInfo?
    private var mapAnnotation: IPInfoAnnotation?
    
    // Створюємо карту та її помічника як lazy-властивості.
    // Вони будуть ініціалізовані лише один раз при першому зверненні.
    private lazy var mapHelper: MapViewHelper = MapViewHelper()
    
    private lazy var mapView: MKMapView = {
        let mapView = MKMapView()
        mapView.setupForIPLocation()
        mapView.delegate = self.mapHelper
        mapView.isHidden = true // Початково прихована до завантаження даних
        return mapView
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        loadIPInfo() // Завантажуємо дані при першому завантаженні view
    }
    
    deinit {
        // Очищуємо делегат, щоб уникнути витоків пам'яті
        mapView.delegate = nil
    }

    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = NSLocalizedString("IP Info", comment: "")

        // Scroll View
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)

        // Content View
        scrollView.addSubview(contentView)
        
        // Map View
        // Додаємо карту до ієрархії одразу
        contentView.addSubview(mapView)

        // Info Container
        infoContainerView.backgroundColor = UIColor.secondarySystemBackground
        infoContainerView.layer.cornerRadius = 16
        infoContainerView.layer.shadowColor = UIColor.label.cgColor
        infoContainerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        infoContainerView.layer.shadowRadius = 8
        infoContainerView.layer.shadowOpacity = 0.1
        contentView.addSubview(infoContainerView)

        setupInfoLabels()
        setupLoadingView()
        setupErrorView()

        // Initial state
        showLoadingState()
    }

    private func setupInfoLabels() {
        let headerLabels = [ipHeaderLabel, locationHeaderLabel, regionHeaderLabel,
                           countryHeaderLabel, timezoneHeaderLabel, ispHeaderLabel,
                           organizationHeaderLabel, coordinatesHeaderLabel]
        
        let valueLabels = [ipLabel, locationLabel, regionLabel, countryLabel,
                          timezoneLabel, ispLabel, organizationLabel, coordinatesLabel]
        
        // Headers setup
        for (index, label) in headerLabels.enumerated() {
            label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.textColor = UIColor.secondaryLabel
            label.numberOfLines = 1
            
            switch index {
            case 0: label.text = NSLocalizedString("ip_address", comment: "")
            case 1: label.text = NSLocalizedString("location", comment: "")
            case 2: label.text = NSLocalizedString("region", comment: "")
            case 3: label.text = NSLocalizedString("country", comment: "")
            case 4: label.text = NSLocalizedString("timezone", comment: "")
            case 5: label.text = NSLocalizedString("isp", comment: "")
            case 6: label.text = NSLocalizedString("organization", comment: "")
            case 7: label.text = NSLocalizedString("coordinates", comment: "")
            default: break
            }
            
            infoContainerView.addSubview(label)
        }
        
        // Values setup
        for label in valueLabels {
            label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
            label.textColor = UIColor.label
            label.numberOfLines = 0
            infoContainerView.addSubview(label)
        }
    }

    private func setupLoadingView() {
        loadingView.backgroundColor = UIColor.systemBackground
        loadingView.layer.cornerRadius = 16
        loadingView.isHidden = true
        contentView.addSubview(loadingView)
        
        loadingIndicator.color = UIColor.systemBlue
        loadingView.addSubview(loadingIndicator)
        
        loadingLabel.text = NSLocalizedString("loading_ip_info", comment: "")
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingLabel.textColor = UIColor.secondaryLabel
        loadingLabel.textAlignment = .center
        loadingView.addSubview(loadingLabel)
    }

    private func setupErrorView() {
        errorView.backgroundColor = UIColor.systemBackground
        errorView.layer.cornerRadius = 16
        errorView.isHidden = true
        contentView.addSubview(errorView)
        
        errorImageView.image = UIImage(systemName: "exclamationmark.triangle")
        errorImageView.tintColor = UIColor.systemOrange
        errorImageView.contentMode = .scaleAspectFit
        errorView.addSubview(errorImageView)
        
        errorLabel.text = NSLocalizedString("failed_to_load_ip_info", comment: "")
        errorLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        errorLabel.textColor = UIColor.label
        errorLabel.textAlignment = .center
        errorLabel.numberOfLines = 0
        errorView.addSubview(errorLabel)
        
        retryButton.setTitle(NSLocalizedString("retry", comment: ""), for: .normal)
        retryButton.setTitleColor(.white, for: .normal)
        retryButton.backgroundColor = UIColor.systemBlue
        retryButton.layer.cornerRadius = 8
        retryButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        retryButton.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        errorView.addSubview(retryButton)
    }

    private func setupNavigationBar() {
        let reloadButton = UIButton(type: .system)
        
        var config = UIButton.Configuration.borderless()
        config.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        config.image = UIImage(systemName: "arrow.clockwise")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        )
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
        
        reloadButton.configuration = config
        reloadButton.addTarget(self, action: #selector(reloadButtonTapped), for: .touchUpInside)
        
        reloadButton.addTarget(self, action: #selector(reloadButtonTouchDown), for: .touchDown)
        reloadButton.addTarget(self, action: #selector(reloadButtonTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
    }

    private func setupConstraints() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mapView.translatesAutoresizingMaskIntoConstraints = false
        infoContainerView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorImageView.translatesAutoresizingMaskIntoConstraints = false
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        retryButton.translatesAutoresizingMaskIntoConstraints = false
        
        let headerLabels = [ipHeaderLabel, locationHeaderLabel, regionHeaderLabel, countryHeaderLabel,
                           timezoneHeaderLabel, ispHeaderLabel, organizationHeaderLabel, coordinatesHeaderLabel]
        let valueLabels = [ipLabel, locationLabel, regionLabel, countryLabel, timezoneLabel,
                          ispLabel, organizationLabel, coordinatesLabel]
        
        for label in headerLabels + valueLabels {
            label.translatesAutoresizingMaskIntoConstraints = false
        }
        
        NSLayoutConstraint.activate([
            // Scroll View
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            
            // Content View
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Map View
            mapView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 250),
            
            // Info Container View
            infoContainerView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            infoContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoContainerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Loading View
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loadingView.heightAnchor.constraint(equalToConstant: 100),
            
            loadingIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor, constant: -10),
            
            loadingLabel.topAnchor.constraint(equalTo: loadingIndicator.bottomAnchor, constant: 8),
            loadingLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 16),
            loadingLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -16),
            
            // Error View
            errorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorView.heightAnchor.constraint(equalToConstant: 200),
            
            errorImageView.topAnchor.constraint(equalTo: errorView.topAnchor, constant: 20),
            errorImageView.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            errorImageView.widthAnchor.constraint(equalToConstant: 50),
            errorImageView.heightAnchor.constraint(equalToConstant: 50),
            
            errorLabel.topAnchor.constraint(equalTo: errorImageView.bottomAnchor, constant: 16),
            errorLabel.leadingAnchor.constraint(equalTo: errorView.leadingAnchor, constant: 16),
            errorLabel.trailingAnchor.constraint(equalTo: errorView.trailingAnchor, constant: -16),
            
            retryButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: 16),
            retryButton.centerXAnchor.constraint(equalTo: errorView.centerXAnchor),
            retryButton.widthAnchor.constraint(equalToConstant: 120),
            retryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        setupInfoLabelsConstraints(headerLabels: headerLabels, valueLabels: valueLabels)
    }

    private func setupInfoLabelsConstraints(headerLabels: [UILabel], valueLabels: [UILabel]) {
        let spacing: CGFloat = 16
        
        for (index, (headerLabel, valueLabel)) in zip(headerLabels, valueLabels).enumerated() {
            let topAnchor = index == 0 ?
                infoContainerView.topAnchor :
                valueLabels[index - 1].bottomAnchor
            let topConstant: CGFloat = index == 0 ? spacing : spacing
            
            NSLayoutConstraint.activate([
                headerLabel.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
                headerLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: spacing),
                headerLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -spacing),
                
                valueLabel.topAnchor.constraint(equalTo: headerLabel.bottomAnchor, constant: 4),
                valueLabel.leadingAnchor.constraint(equalTo: infoContainerView.leadingAnchor, constant: spacing),
                valueLabel.trailingAnchor.constraint(equalTo: infoContainerView.trailingAnchor, constant: -spacing)
            ])
            
            if index == valueLabels.count - 1 {
                valueLabel.bottomAnchor.constraint(equalTo: infoContainerView.bottomAnchor, constant: -spacing).isActive = true
            }
        }
    }

    // MARK: - State Management
    private func showLoadingState() {
        infoContainerView.isHidden = true
        errorView.isHidden = true
        loadingView.isHidden = false
        mapView.isHidden = true
        loadingIndicator.startAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func showContentState() {
        loadingView.isHidden = true
        errorView.isHidden = true
        infoContainerView.isHidden = false
        mapView.isHidden = false
        loadingIndicator.stopAnimating()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func showErrorState(message: String) {
        infoContainerView.isHidden = true
        loadingView.isHidden = true
        errorView.isHidden = false
        mapView.isHidden = true
        loadingIndicator.stopAnimating()
        errorLabel.text = message
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    // MARK: - Data Loading
    private func loadIPInfo() {
        showLoadingState()
        
        NetworkService.shared.fetchIPInfo { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let ipInfo):
                    self.currentIPInfo = ipInfo
                    self.updateUI(with: ipInfo)
                    self.updateMap(with: ipInfo)
                    self.showContentState()
                    
                case .failure(let error):
                    self.showErrorState(message: error.localizedDescription)
                }
            }
        }
    }

    private func updateUI(with ipInfo: IPInfo) {
        ipLabel.text = ipInfo.query
        locationLabel.text = ipInfo.formattedLocation
        regionLabel.text = "\(ipInfo.region) - \(ipInfo.regionName)"
        countryLabel.text = "\(LocalizationManager.shared.localizedCountryName(for: ipInfo.countryCode, fallback: ipInfo.country)) (\(ipInfo.countryCode))"
        timezoneLabel.text = ipInfo.timezone
        ispLabel.text = ipInfo.isp
        organizationLabel.text = ipInfo.org
        coordinatesLabel.text = CLLocationCoordinate2D(latitude: ipInfo.lat, longitude: ipInfo.lon).formattedString
    }

    private func updateMap(with ipInfo: IPInfo) {
        if let existingAnnotation = mapAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }
        
        let annotation = IPInfoAnnotation(ipInfo: ipInfo)
        mapView.addAnnotation(annotation)
        mapAnnotation = annotation
        
        mapView.setRegion(
            center: annotation.coordinate,
            radiusInMeters: 50000,
            animated: true
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }

    // MARK: - Actions
    @objc private func reloadButtonTapped() {
        loadIPInfo()
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        if let button = navigationItem.rightBarButtonItem?.customView {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                button.transform = CGAffineTransform(rotationAngle: .pi)
            } completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                    button.transform = .identity
                }
            }
        }
    }
    
    @objc private func retryButtonTapped() {
        loadIPInfo()
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
    }
    
    @objc private func reloadButtonTouchDown() {
        guard let button = navigationItem.rightBarButtonItem?.customView else { return }
        UIView.animate(withDuration: 0.1) {
            button.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }
    }
    
    @objc private func reloadButtonTouchUp() {
        guard let button = navigationItem.rightBarButtonItem?.customView else { return }
        UIView.animate(withDuration: 0.1) {
            button.transform = .identity
        }
    }
    
    // MARK: - Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            infoContainerView.layer.shadowColor = UIColor.label.cgColor
            
            if let button = navigationItem.rightBarButtonItem?.customView as? UIButton {
                var config = button.configuration
                config?.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
                button.configuration = config
            }
        }
    }
}
