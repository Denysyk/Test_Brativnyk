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
              radiusInMeters > 0,
              radiusInMeters < 40075000 else { // Circumference of Earth
            print("Invalid parameters for setRegion: center=\(center), radius=\(radiusInMeters)")
            return
        }
        
        // Обмежуємо radius для зменшення mesh помилок
        let safeRadius = min(radiusInMeters, 200000) // Max 200km
        
        let region = MKCoordinateRegion(
            center: center,
            latitudinalMeters: safeRadius,
            longitudinalMeters: safeRadius
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
        
        // Встановлюємо регіон з затримкою для стабільності
        DispatchQueue.main.async {
            self.setRegion(region, animated: animated)
        }
    }
    
    /// Оптимізоване налаштування карти для IP локації з мінімізацією mesh помилок
    func setupForIPLocationOptimized() {
        // Базові налаштування
        mapType = .standard
        showsUserLocation = false
        isZoomEnabled = true
        isScrollEnabled = true
        isRotateEnabled = false
        isPitchEnabled = false
        
        // ВАЖЛИВО: Вимикаємо все зайве для мінімізації mesh помилок
        showsBuildings = false
        showsTraffic = false
        showsCompass = false
        showsScale = false
        
        // Встановлюємо фільтр POI
        pointOfInterestFilter = .excludingAll
        
        // Встановлюємо camera constraints для обмеження zoom
        let cameraConstraints = MKMapView.CameraBoundary(
            coordinateRegion: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
                latitudinalMeters: 40075000, // Circumference of Earth
                longitudinalMeters: 40075000
            )
        )
        setCameraBoundary(cameraConstraints, animated: false)
        
        let zoomRange = MKMapView.CameraZoomRange(
            minCenterCoordinateDistance: 1000,    // 1km мінімум
            maxCenterCoordinateDistance: 10000000  // 10,000km максимум
        )
        setCameraZoomRange(zoomRange, animated: false)
        
        // Стиль карти
        layer.cornerRadius = 16
        clipsToBounds = true
        
        // Subtle border
        layer.borderWidth = 0.5
        layer.borderColor = UIColor.separator.cgColor
        
        // Interaction
        isUserInteractionEnabled = true
        
        // КРИТИЧНО: Налаштування для зменшення mesh помилок
        // Встановлюємо preferredConfiguration для iOS 17+
        if #available(iOS 17.0, *) {
            let config = MKStandardMapConfiguration()
            config.emphasisStyle = .muted
            config.pointOfInterestFilter = .excludingAll
            config.showsTraffic = false
            preferredConfiguration = config
        }
        
        // Додаткові оптимізації для зменшення навантаження (iOS 16+)
        selectableMapFeatures = []
    }
    
    /// Legacy method for backward compatibility
    func setupForIPLocation() {
        setupForIPLocationOptimized()
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
}

// MARK: - CLLocationCoordinate2D Extensions
extension CLLocationCoordinate2D {
    
    /// Покращена перевірка валідності з додатковими обмеженнями
    var isValid: Bool {
        // Базові перевірки
        guard CLLocationCoordinate2DIsValid(self) else { return false }
        
        // Перевірка на нулеві координати (може бути проблемним для деяких API)
        guard !(latitude == 0.0 && longitude == 0.0) else { return false }
        
        // Перевірка на валідні діапазони
        guard abs(latitude) <= 90.0 && abs(longitude) <= 180.0 else { return false }
        
        // Перевірка на finite значення
        guard latitude.isFinite && longitude.isFinite else { return false }
        
        // Перевірка на NaN та Infinite
        guard !latitude.isNaN && !longitude.isNaN &&
              !latitude.isInfinite && !longitude.isInfinite else { return false }
        
        // Додаткові перевірки на розумні значення
        // Виключаємо екстремальні значення, які можуть викликати mesh помилки
        guard abs(latitude) >= 0.000001 || abs(longitude) >= 0.000001 else { return false }
        
        return true
    }
    
    /// Безпечне форматування координат
    var formattedString: String {
        guard isValid else {
            return NSLocalizedString("Invalid coordinates", comment: "")
        }
        
        return LocalizationManager.shared.formatCoordinates(
            latitude: latitude,
            longitude: longitude
        )
    }
    
    /// Безпечна відстань між координатами
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
        
        // Валідація координат з кращим fallback
        guard coord.isValid else {
            print("Invalid coordinates from IPInfo: lat=\(ipInfo.lat), lon=\(ipInfo.lon)")
            // Повертаємо безпечні координати замість 0,0
            return CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194) // San Francisco as fallback
        }
        
        return coord
    }
    
    var title: String? {
        let cityName = ipInfo.city.trimmingCharacters(in: .whitespacesAndNewlines)
        return cityName.isEmpty ? "Unknown Location" : cityName
    }
    
    var subtitle: String? {
        let location = ipInfo.formattedLocation.trimmingCharacters(in: .whitespacesAndNewlines)
        return location.isEmpty ? "No location data" : location
    }
    
    init(ipInfo: IPInfo) {
        self.ipInfo = ipInfo
        super.init()
    }
}

// MARK: - Enhanced Map Delegate Helper
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
    
    // ВАЖЛИВО: Оптимізований regionDidChangeAnimated для зменшення mesh помилок
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
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
            return
        }
        
        // Обмежуємо надто далекі зуми для зменшення mesh помилок
        let maxLatitudeDelta: CLLocationDegrees = 45.0   // Ще більше зменшено
        let maxLongitudeDelta: CLLocationDegrees = 90.0  // Ще більше зменшено
        let minLatitudeDelta: CLLocationDegrees = 0.01   // Збільшено мінімум
        let minLongitudeDelta: CLLocationDegrees = 0.01
        
        var needsUpdate = false
        var newLatitudeDelta = currentRegion.span.latitudeDelta
        var newLongitudeDelta = currentRegion.span.longitudeDelta
        
        // Перевіряємо максимальні значення
        if currentRegion.span.latitudeDelta > maxLatitudeDelta {
            newLatitudeDelta = maxLatitudeDelta
            needsUpdate = true
        }
        if currentRegion.span.longitudeDelta > maxLongitudeDelta {
            newLongitudeDelta = maxLongitudeDelta
            needsUpdate = true
        }
        
        // Перевіряємо мінімальні значення
        if currentRegion.span.latitudeDelta < minLatitudeDelta {
            newLatitudeDelta = minLatitudeDelta
            needsUpdate = true
        }
        if currentRegion.span.longitudeDelta < minLongitudeDelta {
            newLongitudeDelta = minLongitudeDelta
            needsUpdate = true
        }
        
        if needsUpdate {
            let constrainedRegion = MKCoordinateRegion(
                center: currentRegion.center,
                span: MKCoordinateSpan(
                    latitudeDelta: newLatitudeDelta,
                    longitudeDelta: newLongitudeDelta
                )
            )
            
            mapView.setRegion(constrainedRegion, animated: false)
        }
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? IPLocationAnnotation else { return }
        
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
    
    // ВАЖЛИВО: Додаємо delegate методи для мінімізації mesh помилок
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        // Повертаємо мінімальний renderer для зменшення навантаження
        return MKOverlayRenderer(overlay: overlay)
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        // Додаткові оптимізації при початку завантаження карти
        mapView.showsBuildings = false
        mapView.showsTraffic = false
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        // Підтверджуємо оптимізації після завантаження карти
        mapView.showsBuildings = false
        mapView.showsTraffic = false
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
