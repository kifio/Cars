//
//  Repository.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import Alamofire
import Foundation

class Repository {
    
    private static let url = "https://raw.githubusercontent.com/Gary111/TrashCan/master/2000_cars.json"
    
    private let cache = Cache()
    
    func fetchCars(onCarsFetched: @escaping ([Car]) -> ()) {
        AF.request(Repository.url).responseData { response in
            if let err = response.error {
                print(err.localizedDescription)
                self.cache.fetch(onCarsFetched)
            } else if let data = response.value {
                self.handleResponse(data, onCarsFetched)
            }
        }
    }
    
    private func handleResponse(_ data: Data, _ onCarsFetched: ([Car]) -> Void) {
        do {
            let cars = try JSONDecoder().decode([Car].self, from: data)
            self.cache.updateAndFetch(cars: cars, onCarsFetched)
        } catch let err {
            print(err)
            self.cache.fetch(onCarsFetched)
        }
    }
}
