//
//  MapKit+Extensions.swift
//  Test_Brativnyk
//
//  Created by Denys Brativnyk on 20.07.2025.
//

import Foundation
import MapKit
import UIKit

// MARK: - MKMapView Extensions
extension MKMapView {
    
    /// Sets the map region to show a specific coordinate with a given radius
    func setRegion(center: CLLocationCoordinate2D, radiusInMeters: CLLocationDistance, animated: Bool = true) {
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
        setRegion(region, animated: animated)
    }
    
    /// Adds a custom pin annotation with styling
    func addStyledAnnotation(
        coordinate: CLLocationCoordinate2D,
        title: String?,
        subtitle: String?
    ) -> MKPointAnnotation {
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = title
        annotation.subtitle = subtitle
        
        addAnnotation(annotation)
        return annotation
    }
    
    /// Removes all annotations except user location
    func removeAllAnnotations() {
        let annotationsToRemove = annotations.filter { !($0 is MKUserLocation) }
        removeAnnotations(annotationsToRemove)
    }
    
    /// Sets up map for IP location display
    func setupForIPLocation() {
        mapType = .standard
        showsUserLocation = false
        isZoomEnabled = true
        isScrollEnabled = true
        isRotateEnabled = true
        isPitchEnabled = false
        
        // Add subtle style
        layer.cornerRadius = ThemeManager.CornerRadius.large
        clipsToBounds = true
        
        // Add border for better visibility
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.cgColor
    }
}

// MARK: - CLLocationCoordinate2D Extensions
extension CLLocationCoordinate2D {
    
    /// Checks if coordinate is valid
    var isValid: Bool {
        return CLLocationCoordinate2DIsValid(self)
    }
    
    /// Returns formatted string representation
    var formattedString: String {
        return LocalizationManager.shared.formatCoordinates(
            latitude: latitude,
            longitude: longitude
        )
    }
    
    /// Distance between two coordinates in meters
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return from.distance(from: to)
    }
}

// MARK: - Custom Map Pin View
class IPLocationAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let annotation = newValue as? MKPointAnnotation else { return }
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            // Customize marker appearance
            markerTintColor = UIColor.systemRed
            glyphTintColor = UIColor.white
            glyphImage = UIImage(systemName: "location.fill")
            
            // Add subtle animation
            animatesWhenAdded = true
            
            // Custom display priority
            displayPriority = .required
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        annotation = nil
    }
}

// MARK: - Map Annotation Protocol
protocol IPLocationAnnotation: MKAnnotation {
    var ipInfo: IPInfo { get }
}

// MARK: - Custom IP Location Annotation
class IPInfoAnnotation: NSObject, IPLocationAnnotation {
    let ipInfo: IPInfo
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: ipInfo.lat, longitude: ipInfo.lon)
    }
    
    var title: String? {
        return ipInfo.city
    }
    
    var subtitle: String? {
        return ipInfo.formattedLocation
    }
    
    init(ipInfo: IPInfo) {
        self.ipInfo = ipInfo
        super.init()
    }
}

// MARK: - Map Delegate Helper
class MapViewHelper: NSObject, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is IPLocationAnnotation else { return nil }
        
        let identifier = "IPLocationPin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? IPLocationAnnotationView
        
        if annotationView == nil {
            annotationView = IPLocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? IPLocationAnnotation else { return }
        
        // Handle tap on callout accessory (detail disclosure button)
        let alertController = UIAlertController(
            title: annotation.ipInfo.city,
            message: """
            \(LocalizationManager.IPInfo.country): \(annotation.ipInfo.country)
            \(LocalizationManager.IPInfo.region): \(annotation.ipInfo.regionName)
            \(LocalizationManager.IPInfo.timezone): \(annotation.ipInfo.timezone)
            \(LocalizationManager.IPInfo.isp): \(annotation.ipInfo.isp)
            """,
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(
            title: LocalizationManager.Common.ok,
            style: .default
        ))
        
        // Get the top view controller to present the alert
        if let topController = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow })?
            .rootViewController {
            
            var presentingController = topController
            while let presented = presentingController.presentedViewController {
                presentingController = presented
            }
            
            presentingController.present(alertController, animated: true)
        }
    }
}

// MARK: - UIApplication Extension for Top View Controller
extension UIApplication {
    var topViewController: UIViewController? {
        return connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }?
            .rootViewController?
            .topMostViewController
    }
}

extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = presentedViewController {
            return presented.topMostViewController
        }
        
        if let navigationController = self as? UINavigationController {
            return navigationController.visibleViewController?.topMostViewController ?? self
        }
        
        if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.topMostViewController ?? self
        }
        
        return self
    }
}
