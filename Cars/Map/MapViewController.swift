//
//  ViewController.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import Mapbox

class MapViewController: UIViewController {
    
    static let initialZoomLevel = 9.0
    
    private var updating: Bool = false
    
    private var mapView: MGLMapView!
    private var userLocation: MGLUserLocation?
    private let presenter: MapPresenter
    
    private let polylineController = PolyLineController()
    
    init(presenter: MapPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupMapView()
    }
    
    private func setupMapView() {
        self.mapView = MGLMapView(frame: view.bounds)
        self.mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapView.showsUserLocation = true
        self.mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        self.mapView.delegate = self
        view.addSubview(mapView)
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        
        for recognizer in mapView.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        
        mapView.addGestureRecognizer(singleTap)
    }
}

// MARK: Polyline
extension MapViewController {
    
    @objc func handleMapTap(sender: UITapGestureRecognizer) {
        let spot = sender.location(in: mapView)
        let features = mapView.visibleFeatures(at: spot, styleLayerIdentifiers: Set([Constants.layer]))
        if let feature = features.first,
            let userLocation = self.userLocation?.location?.coordinate,
            let id = feature.attribute(forKey: Constants.id) as? Int {
            self.showCarDetail(carId: id)
            self.showRoute(from: userLocation, to: feature.coordinate)
        } else {
            self.dismiss()
        }
    }
    
    private func showCarDetail(carId: Int) {
        self.presenter.showDetails(target: self, id: carId, completion: { detailsHeight in
            var frame = self.mapView.frame
            frame.size = CGSize(width: frame.width, height: frame.height - detailsHeight)
            self.mapView.frame = frame
        })
    }
    
    private func showRoute(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) {
        self.presenter.showRoute(
            fromLon: from.longitude,
            fromLat: from.latitude,
            toLon: to.longitude,
            toLat: to.latitude,
            completion: { [weak self] routeViewModel in
                guard let style = self?.mapView.style else { return }
                DispatchQueue.main.async(execute: {
                    self?.animateCamera(polyline: routeViewModel.polyline)
                    self?.polylineController.addPolyline(routeViewModel.polyline, to: style)
                    self?.polylineController.animatePolyline()
                })
        })
    }
    
    private func dismiss() {
        guard let style = self.mapView.style else { return }
        self.polylineController.clear(style)
        UIView.animate(withDuration: 0.3) { [weak self] in
            if let controller = self {
                controller.mapView.frame = controller.view.frame
            }
        }
        self.presenter.removeDetailsViewController(target: self)
    }
    
    private func animateCamera(polyline: [CLLocationCoordinate2D]) {
        if let south = polyline.min(by: { (loc0, loc1) -> Bool in
            return loc0.latitude < loc1.latitude
        })?.latitude,
            
            let west = polyline.min(by: { (loc0, loc1) -> Bool in
                return loc0.longitude < loc1.longitude
            })?.longitude,
            
            let north = polyline.max(by: { (loc0, loc1) -> Bool in
                return loc0.latitude < loc1.latitude
            })?.latitude,
            
            let east = polyline.max(by: { (loc0, loc1) -> Bool in
                return loc0.longitude < loc1.longitude
            })?.longitude {
            
            let targetbounds: MGLCoordinateBounds = MGLCoordinateBounds(
                sw: CLLocationCoordinate2D(latitude: south, longitude: west),
                ne: CLLocationCoordinate2D(latitude: north, longitude: east))
            
            let inset: CGFloat = 24.0
            let padding = UIEdgeInsets(
                top: inset,
                left: inset,
                bottom: inset,
                right: inset
            )
            
            let camera = self.mapView.cameraThatFitsCoordinateBounds(targetbounds, edgePadding: padding)
            
            self.mapView.setCamera(camera, animated: true)
        }
    }
}


// MARK: - MGLMapViewDelegate
extension MapViewController: MGLMapViewDelegate {
    func mapView(
        _ mapView: MGLMapView,
        regionDidChangeWith: MGLCameraChangeReason,
        animated: Bool
    ) {
        let bounds = mapView.convert(mapView.frame, toCoordinateBoundsFrom: mapView)
        
        if !self.updating {
            self.updating = true
            self.presenter.showCars(
                left: bounds.sw.longitude,
                top: bounds.ne.latitude,
                right: bounds.ne.longitude,
                bottom: bounds.sw.latitude,
                completion: { [weak self] cars in
                    if !cars.isEmpty {
                        self?.addItemsToMap(mapView, cars)
                    } else {
                        self?.updating = false
                    }
            })
        }
    }
    
    func mapView(_ mapView: MGLMapView, didUpdate userLocation: MGLUserLocation?) {
        self.userLocation = userLocation
    }
}

// MARK: - Map updates
extension MapViewController {
    
    struct Constants {
        static let blue = "blue"
        static let black = "black"
        static let source = "cars-source"
        static let layer = "cars-layer"
        static let color = "color"
        static let rotation = "rotation"
        static let id = "id"
    }
    
    func addItemsToMap(_ mapView: MGLMapView, _ cars: [CarViewModel]) {
        guard let style = mapView.style else { return }
        
        if style.image(forName: Constants.blue) == nil {
            DispatchQueue.main.async(execute: {
                style.setImage(UIImage(named: Constants.blue)!, forName: Constants.blue)
            })
        }
        
        if style.image(forName: Constants.black) == nil {
            DispatchQueue.main.async(execute: {
                style.setImage(UIImage(named: Constants.black)!, forName: Constants.black)
            })
        }
        
        let features = mapToFeatures(cars)
        let source = getSource(style)
        setupSymbolsLayer(style, source)
        
        DispatchQueue.main.async(execute: {
            source.shape = MGLShapeCollectionFeature(shapes: features)
            self.updating = false
        })
    }
    
    private func getSource(_ style: MGLStyle) -> MGLShapeSource {
        if let source = style.source(withIdentifier: Constants.source) as? MGLShapeSource {
            return source
        }
        
        let source = MGLShapeSource(identifier: Constants.source, features: [], options: nil)
        style.addSource(source)
        return source
    }
    
    private func setupSymbolsLayer(
        _ style: MGLStyle,
        _ source: MGLShapeSource
    ) {
        if style.layer(withIdentifier: Constants.layer) == nil {
            let symbols = MGLSymbolStyleLayer(identifier: Constants.layer, source: source)
            symbols.iconImageName = NSExpression(forKeyPath: Constants.color)
            symbols.iconRotation = NSExpression(forKeyPath: Constants.rotation)
            symbols.iconScale = NSExpression(forConstantValue: 0.5)
            style.addLayer(symbols)
        }
    }
    
    private func mapToFeatures(_ cars: [CarViewModel]) -> [MGLPointFeature] {
        var features = [MGLPointFeature]()
        for car in cars {
            
            let coordinate = CLLocationCoordinate2D(
                latitude: car.latitude,
                longitude: car.longitude
            )
            
            let feature = MGLPointFeature()
            feature.coordinate = coordinate
            
            feature.attributes = [
                Constants.id: car.id,
                Constants.rotation: car.angle,
                Constants.color: car.color
            ]
            
            features.append(feature)
        }
        return features
    }
}
