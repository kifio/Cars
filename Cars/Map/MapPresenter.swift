//
//  MapPresenter.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import Foundation

protocol MapPresenter {
    func showCars(
        left: Double,
        top: Double,
        right: Double,
        bottom: Double,
        completion: @escaping ([CarViewModel]) -> Void)
    func showRoute()
    func showDetails()
}

struct CarViewModel {
    let color: String
    let angle: Int
    let latitude: Double
    let longitude: Double
    
    init(car: Car) {
        self.color = car.color
        self.angle = car.angle
        self.latitude = car.latitude
        self.longitude = car.longitude
    }
}

class MapPresenterImpl: MapPresenter {
    
    let interactor: MapInteractor
    let router: MapRouter
    
    init(interactor: MapInteractor, router: MapRouter) {
        self.interactor = interactor
        self.router = router
    }
    
    func showCars(left: Double,
                  top: Double,
                  right: Double,
                  bottom: Double,
                  completion: @escaping ([CarViewModel]) -> Void) {
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
    
    func showRoute() {
        
    }
    
    func showDetails() {
        
    }
}
