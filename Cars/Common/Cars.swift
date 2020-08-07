//
//  Cars.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

struct Car : Decodable {
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case plateNumber = "plate_number"
        case name = "name"
        case color = "color"
        case angle = "angle"
        case fuelPercentage = "fuel_percentage"
        case latitude = "latitude"
        case longitude = "longitude"
    }
    
    let id: Int
    let plateNumber: String
    let name: String
    let color: String
    let angle: Int
    let fuelPercentage: Int
    let latitude: Double
    let longitude: Double
}
