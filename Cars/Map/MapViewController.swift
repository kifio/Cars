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
    private let presenter: MapPresenter
    
    init(presenter: MapPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMapView()
    }
    
    private func setupMapView() {
        let mapView = MGLMapView(frame: view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.showsUserLocation = true
        mapView.setUserTrackingMode(.follow, animated: true, completionHandler: nil)
        mapView.delegate = self
        view.addSubview(mapView)
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
    }
    
    func addItemsToMap(_ mapView: MGLMapView, _ cars: [CarViewModel]) {
        guard let style = mapView.style else { return }
        
        if style.image(forName: Constants.blue) == nil {
            style.setImage(UIImage(named: Constants.blue)!, forName: Constants.blue)
        }
        
        if style.image(forName: Constants.black) == nil {
            style.setImage(UIImage(named: Constants.black)!, forName: Constants.black)
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
                Constants.rotation: car.angle,
                Constants.color: car.color
            ]
            
            features.append(feature)
        }
        return features
    }
}
