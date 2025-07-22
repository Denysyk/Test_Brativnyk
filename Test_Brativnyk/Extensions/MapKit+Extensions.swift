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
        guard center.isValid,
              radiusInMeters.isFinite,
              !radiusInMeters.isNaN,
              !radiusInMeters.isInfinite,
              radiusInMeters > 0 else {
            print("Invalid parameters for setRegion: center=\(center), radius=\(radiusInMeters)")
            return
        }
        
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: radiusInMeters,
            longitudinalMeters: radiusInMeters
        )
        
        // Додаткова перевірка валідності region
        guard region.center.latitude.isFinite &&
              region.center.longitude.isFinite &&
              region.span.latitudeDelta.isFinite &&
              region.span.longitudeDelta.isFinite &&
              !region.center.latitude.isNaN &&
              !region.center.longitude.isNaN &&
              !region.span.latitudeDelta.isNaN &&
              !region.span.longitudeDelta.isNaN &&
              !region.center.latitude.isInfinite &&
              !region.center.longitude.isInfinite &&
              !region.span.latitudeDelta.isInfinite &&
              !region.span.longitudeDelta.isInfinite else {
            print("Invalid region calculated, skipping setRegion")
            return
        }
        
        setRegion(region, animated: animated)
    }
    
    /// Adds a custom pin annotation with styling
    func addStyledAnnotation(
        coordinate: CLLocationCoordinate2D,
        title: String?,
        subtitle: String?
    ) -> MKPointAnnotation? {
        guard coordinate.isValid else { return nil }
        
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
        isRotateEnabled = false
        isPitchEnabled = false
        
        // Add subtle style
        layer.cornerRadius = 16
        clipsToBounds = true
        
        // Add border for better visibility
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.cgColor
        
        // Prevent automatic region changes
        isUserInteractionEnabled = true
    }
}

// MARK: - CLLocationCoordinate2D Extensions
extension CLLocationCoordinate2D {
    
    /// Checks if coordinate is valid with additional NaN checks
    var isValid: Bool {
        return CLLocationCoordinate2DIsValid(self) &&
               (latitude != 0.0 || longitude != 0.0) &&
               abs(latitude) <= 90.0 &&
               abs(longitude) <= 180.0 &&
               latitude.isFinite &&
               longitude.isFinite &&
               !latitude.isNaN &&
               !longitude.isNaN &&
               !latitude.isInfinite &&
               !longitude.isInfinite
    }
    
    /// Returns formatted string representation
    var formattedString: String {
        guard isValid else {
            return "Invalid coordinates"
        }
        
        return LocalizationManager.shared.formatCoordinates(
            latitude: latitude,
            longitude: longitude
        )
    }
    
    /// Distance between two coordinates in meters
    func distance(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        guard isValid && coordinate.isValid else { return 0 }
        
        let from = CLLocation(latitude: latitude, longitude: longitude)
        let to = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let distance = from.distance(from: to)
        
        // Перевіряємо валідність результату
        guard distance.isFinite && !distance.isNaN && !distance.isInfinite else {
            return 0
        }
        
        return distance
    }
}

// MARK: - Custom Map Pin View
class IPLocationAnnotationView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let newAnnotation = newValue as? IPInfoAnnotation,
                  newAnnotation.coordinate.isValid else { return }
            
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            
            // Customize marker appearance
            markerTintColor = UIColor.systemRed
            glyphTintColor = UIColor.white
            glyphImage = UIImage(systemName: "location.fill")
            
            // Add animation only when needed
            if animatesWhenAdded != true {
                animatesWhenAdded = true
            }
            
            // Custom display priority
            displayPriority = .required
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        annotation = nil
        canShowCallout = false
        animatesWhenAdded = false
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
        let coord = CLLocationCoordinate2D(latitude: ipInfo.lat, longitude: ipInfo.lon)
        
        // Валідація координат з fallback
        guard coord.isValid else {
            print("Invalid coordinates from IPInfo: lat=\(ipInfo.lat), lon=\(ipInfo.lon)")
            // Повертаємо координати центру світу як fallback
            return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        }
        
        return coord
    }
    
    var title: String? {
        return ipInfo.city.isEmpty ? "Unknown Location" : ipInfo.city
    }
    
    var subtitle: String? {
        return ipInfo.formattedLocation.isEmpty ? "No location data" : ipInfo.formattedLocation
    }
    
    init(ipInfo: IPInfo) {
        self.ipInfo = ipInfo
        super.init()
    }
}

// MARK: - Map Delegate Helper
class MapViewHelper: NSObject, MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let annotation = annotation as? IPLocationAnnotation,
              annotation.coordinate.isValid else { return nil }
        
        let identifier = "IPLocationPin"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? IPLocationAnnotationView
        
        if annotationView == nil {
            annotationView = IPLocationAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        } else {
            annotationView?.annotation = annotation
        }
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        // Додаткова перевірка при виборі анотації
        guard view.annotation is IPLocationAnnotation else { return }
        
        // Легка анімація при виборі
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        // Очищуємо анімації при deselect
        view.transform = .identity
        view.layer.removeAllAnimations()
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // Обмежуємо надто далекі зуми для стабільності
        let maxLatitudeDelta: CLLocationDegrees = 180.0
        let maxLongitudeDelta: CLLocationDegrees = 360.0
        
        let currentRegion = mapView.region
        
        // Перевіряємо валідність поточного region
        guard currentRegion.center.latitude.isFinite &&
              currentRegion.center.longitude.isFinite &&
              currentRegion.span.latitudeDelta.isFinite &&
              currentRegion.span.longitudeDelta.isFinite &&
              !currentRegion.center.latitude.isNaN &&
              !currentRegion.center.longitude.isNaN &&
              !currentRegion.span.latitudeDelta.isNaN &&
              !currentRegion.span.longitudeDelta.isNaN else {
            print("Invalid region detected in regionDidChangeAnimated")
            return
        }
        
        if currentRegion.span.latitudeDelta > maxLatitudeDelta ||
           currentRegion.span.longitudeDelta > maxLongitudeDelta {
            
            let constrainedRegion = MKCoordinateRegion(
                center: currentRegion.center,
                span: MKCoordinateSpan(
                    latitudeDelta: min(currentRegion.span.latitudeDelta, maxLatitudeDelta),
                    longitudeDelta: min(currentRegion.span.longitudeDelta, maxLongitudeDelta)
                )
            )
            
            mapView.setRegion(constrainedRegion, animated: false)
        }
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
