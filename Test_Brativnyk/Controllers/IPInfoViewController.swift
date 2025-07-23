//
//  IPInfoViewController.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit

class IPInfoViewController: UIViewController {

    // MARK: - UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mapView = IPMapView()
    private let infoCardView = IPInfoCardView()
    private let loadingView = LoadingStateView()
    private let errorView = ErrorStateView()

    // MARK: - Managers
    private let ipInfoManager = IPInfoManager()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        setupNavigationBar()
        setupDelegates()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.ipInfoManager.loadIPInfo()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor.systemBackground
        title = NSLocalizedString("IP Info", comment: "")

        setupScrollView()
        addSubviews()
    }
    
    private func setupScrollView() {
        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func addSubviews() {
        [mapView, infoCardView, loadingView, errorView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        [scrollView, contentView, mapView, infoCardView, loadingView, errorView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
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
            
            // Info Card View
            infoCardView.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            infoCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            infoCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            infoCardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            // Loading View
            loadingView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            loadingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            loadingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            loadingView.heightAnchor.constraint(equalToConstant: 100),
            
            // Error View
            errorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            errorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            errorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            errorView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }

    private func setupNavigationBar() {
        let reloadButton = UIButton.createNavigationButton(
            image: "arrow.clockwise",
            target: self,
            action: #selector(reloadButtonTapped)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reloadButton)
    }
    
    private func setupDelegates() {
        ipInfoManager.delegate = self
        errorView.delegate = self
    }

    // MARK: - State Management
    private func showLoadingState() {
        infoCardView.isHidden = true
        errorView.hide()
        mapView.hideMap()
        loadingView.show()
        navigationItem.rightBarButtonItem?.isEnabled = false
    }

    private func showContentState() {
        loadingView.hide()
        errorView.hide()
        infoCardView.isHidden = false
        mapView.showMap()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    private func showErrorState(message: String) {
        infoCardView.isHidden = true
        loadingView.hide()
        mapView.hideMap()
        errorView.show(message: message)
        navigationItem.rightBarButtonItem?.isEnabled = true
    }

    // MARK: - Actions
    @objc private func reloadButtonTapped() {
        ipInfoManager.reloadIPInfo()
        animateReloadButton()
        HapticFeedback.impact(.medium)
    }
    
    private func animateReloadButton() {
        guard let button = navigationItem.rightBarButtonItem?.customView else { return }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
            button.transform = CGAffineTransform(rotationAngle: .pi)
        } completion: { _ in
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8) {
                button.transform = .identity
            }
        }
    }
    
    // MARK: - Theme Support
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateNavigationButtonAppearance()
        }
    }
    
    private func updateNavigationButtonAppearance() {
        guard let button = navigationItem.rightBarButtonItem?.customView as? UIButton else { return }
        
        var config = button.configuration
        config?.baseForegroundColor = traitCollection.userInterfaceStyle == .dark ? UIColor.white : UIColor.black
        button.configuration = config
    }
}

// MARK: - IPInfoManagerDelegate
extension IPInfoViewController: IPInfoManagerDelegate {
    func didStartLoading() {
        showLoadingState()
    }
    
    func didReceiveIPInfo(_ ipInfo: IPInfo) {
        infoCardView.configure(with: ipInfo)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.mapView.updateLocation(with: ipInfo)
            self.showContentState()
        }
    }
    
    func didFailWithError(_ error: NetworkError) {
        showErrorState(message: error.localizedDescription)
    }
}

// MARK: - ErrorStateViewDelegate
extension IPInfoViewController: ErrorStateViewDelegate {
    func didTapRetry() {
        ipInfoManager.reloadIPInfo()
    }
}
