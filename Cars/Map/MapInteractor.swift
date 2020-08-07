//
//  MapInteractor.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import Foundation

protocol MapInteractor {
    func getCars(
        left: Double,
        top: Double,
        right: Double,
        bottom: Double,
        completion: @escaping ([Car]) -> Void
    )
}

class MapInteractorImpl: MapInteractor {
    
    private let repository: Repository
    private var cars = [Car]()
    
    init(repository: Repository) {
        self.repository = repository
        fetchCars()
    }
    
    func getCars(
        left: Double,
        top: Double,
        right: Double,
        bottom: Double,
        completion: @escaping ([Car]) -> Void) {
        completion(self.cars.filter {
            $0.isInBounds(left, top, right, bottom)
        })
    }
    
    private func fetchCars() {
        DispatchQueue.global(qos: .userInteractive).async {
            self.repository.fetchCars(onCarsFetched: { [weak self] cars in
                self?.cars.append(contentsOf: cars)
            })
        }
    }
}

private extension Car {
    func isInBounds(_ left: Double, _ top: Double, _ right: Double, _ bottom: Double) -> Bool {
        return self.latitude >= bottom && self.latitude <= top
            && self.longitude >= left && self.longitude <= right
    }
}
