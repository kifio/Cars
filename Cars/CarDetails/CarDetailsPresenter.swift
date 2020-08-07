//
//  CarDetailsPresenter.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import UIKit

struct CarDetailsViewModel {
    let name: String
    let plateNumber: String
    let fuelPercentage: String
}

protocol CarDetailsPresenter {
    func getCarDetailsViewModel() -> CarDetailsViewModel
    func downloadImage(completion: @escaping (UIImage) -> Void)
}

class CarDetailsPresenterImpl: CarDetailsPresenter{

    struct Constants {
        static let imageUrl = "https://picsum.photos/300/200"
    }
    
    private let car: Car
    private let interactor: CarDetailsInteractor
    
    init(car: Car, interactor: CarDetailsInteractor) {
        self.car = car
        self.interactor = interactor
    }
    
    func getCarDetailsViewModel() -> CarDetailsViewModel {
        return CarDetailsViewModel(
            name: car.name,
            plateNumber: car.plateNumber,
            fuelPercentage: "\(car.fuelPercentage)%"
        )
    }
    
    func downloadImage(completion: @escaping (UIImage) -> Void) {
        self.interactor.downloadImage(Constants.imageUrl, completion: completion)
    }
}
