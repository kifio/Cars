//
//  MapPresenter.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit
import Polyline
import CoreLocation

struct CarViewModel {
    let id: Int
    let color: String
    let angle: Int
    let latitude: Double
    let longitude: Double
    
    init(car: Car) {
        self.id = car.id
        self.color = car.color
        self.angle = car.angle
        self.latitude = car.latitude
        self.longitude = car.longitude
    }
}

struct RouteViewModel {
    let polyline: [CLLocationCoordinate2D]
}

protocol MapPresenter {
    func showCars(
        left: Double,
        top: Double,
        right: Double,
        bottom: Double,
        completion: @escaping ([CarViewModel]) -> Void)
    
    func showRoute(
        fromLon: Double,
        fromLat: Double,
        toLon: Double,
        toLat: Double,
        completion: @escaping (RouteViewModel) -> Void)
    
    func showDetails(target: UIViewController, id: Int, completion: @escaping (CGFloat) -> Void)
    
    func removeDetailsViewController(target: UIViewController)
}

class MapPresenterImpl: MapPresenter {
    
    let interactor: MapInteractor
    let router: MapRouter
    
    init(interactor: MapInteractor, router: MapRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func showCars(
        left: Double,
        top: Double,
        right: Double,
        bottom: Double,
        completion: @escaping ([CarViewModel]) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.interactor.getCars(
                left: left,
                top: top,
                right: right,
                bottom: bottom
            ) { (cars) in
                completion(cars.map { CarViewModel(car: $0) })
            }
        }
    }
    
    func showRoute(
        fromLon: Double,
        fromLat: Double,
        toLon: Double,
        toLat: Double,
        completion: @escaping (RouteViewModel) -> Void
    ) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.interactor.getRoute(
                fromLon: fromLon,
                fromLat: fromLat,
                toLon: toLon,
                toLat: toLat
            ) { route in
                let polyline = Polyline(encodedPolyline: route.geometry)
                if let decodedLocations = polyline.locations {
                    completion(RouteViewModel(polyline: decodedLocations.map {
                        $0.coordinate
                    }))
                }
            }
        }
    }
    
    func showDetails(target: UIViewController, id: Int, completion: @escaping (CGFloat) -> Void) {
        if let car = self.interactor.findCar(id: id) {
            self.router.showDetails(target, car, completion)
        }
    }
    
    func removeDetailsViewController(target: UIViewController) {
        self.router.removeDetailsViewController(target)
    }
}
