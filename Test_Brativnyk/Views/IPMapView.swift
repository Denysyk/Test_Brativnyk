//
//  IPMapView.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import UIKit
import MapKit
import CoreLocation

class IPMapView: UIView {
    
    private let mapView = MKMapView()
    private let mapHelper = MapViewHelper()
    private var currentAnnotation: IPInfoAnnotation?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        setupMapView()
        setupConstraints()
    }
    
    private func setupMapView() {
        mapView.setupForIPLocationOptimized()
        mapView.delegate = mapHelper
        mapView.isHidden = true
        
        addSubview(mapView)
    }
    
    private func setupConstraints() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: topAnchor),
            mapView.leadingAnchor.constraint(equalTo: leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func showMap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.mapView.isHidden = false
        }
    }
    
    func hideMap() {
        mapView.isHidden = true
    }
    
    func updateLocation(with ipInfo: IPInfo) {
        removeCurrentAnnotation()
        
        let annotation = IPInfoAnnotation(ipInfo: ipInfo)
        
        guard annotation.coordinate.isValid else {
            print("Invalid coordinates for map annotation")
            return
        }
        
        mapView.addAnnotation(annotation)
        currentAnnotation = annotation
        
        setMapRegion(for: annotation.coordinate)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.mapView.selectAnnotation(annotation, animated: true)
        }
    }
    
    private func removeCurrentAnnotation() {
        if let existingAnnotation = currentAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }
    }
    
    private func setMapRegion(for coordinate: CLLocationCoordinate2D) {
        let limitedRadius: CLLocationDistance = 25000
        let safeRegion = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: limitedRadius,
            longitudinalMeters: limitedRadius
        )
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.mapView.setRegion(safeRegion, animated: true)
        }
    }
    
    deinit {
        mapView.delegate = nil
        mapView.removeAnnotations(mapView.annotations)
    }
}
