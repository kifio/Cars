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
    
    typealias LonLat = (Double, Double)
    
    private static let carsUrl = "https://raw.githubusercontent.com/Gary111/TrashCan/master/2000_cars.json"
    
    private static let routeUrl = "https://api.mapbox.com/directions/v5/mapbox/"
    
    private static let routeRequestParameters: [String:String] = [
        "access_token":"pk.eyJ1IjoiYmVsa2FjYXIiLCJhIjoiY2tkajg3anAyMGM3NzJ2bGhkMXJjZ213bCJ9.XIzfKyb_S9Mhu1-nU96fIQ"
    ]
    
    private let cache = Cache()
    
    func fetchCars(onCarsFetched: @escaping ([Car]) -> ()) {
        AF.request(Repository.carsUrl).responseData { response in
            if let err = response.error {
                print(err.localizedDescription)
                self.cache.fetch(onCarsFetched)
            } else if let data = response.value {
                self.handleCarsResponse(data, onCarsFetched)
            }
        }
    }
    
    private func handleCarsResponse(_ data: Data, _ onCarsFetched: ([Car]) -> Void) {
        do {
            let cars = try JSONDecoder().decode([Car].self, from: data)
            self.cache.updateAndFetch(cars: cars, onCarsFetched)
        } catch let err {
            print(err)
            self.cache.fetch(onCarsFetched)
        }
    }
    
    func fetchRoute(
        from: LonLat,
        to: LonLat,
        onRouteFounded: @escaping (Route) -> ()) {
        guard var routeUrl = URL(string: Repository.routeUrl) else {
            return
        }
        
        // driving - чтобы пресечь ошибку "code":"InvalidInput","message":"Route exceeds maximum distance limitation"}
        routeUrl.appendPathComponent("driving")
        routeUrl.appendPathComponent("\(from.0),\(from.1);\(to.0),\(to.1)")
        print(routeUrl.absoluteString)
        AF.request(
            routeUrl,
            parameters: Repository.routeRequestParameters
        ).responseData { response in
            if let err = response.error {
                print(err.localizedDescription)
            } else if let data = response.value {
                self.handleRoutesResponse(data, onRouteFounded)
            }
        }
    }
    
    private func handleRoutesResponse(_ data: Data, _ onRouteFounded: @escaping (Route) -> ()) {
        do {
            let routes = try JSONDecoder().decode(RouteResponse.self, from: data)
            if !routes.routes.isEmpty {
                onRouteFounded(routes.routes[0])
            }
        } catch let err {
            print(err)
        }
    }
}
