//
//  Route.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import Foundation

struct RouteResponse: Decodable {
    let routes: [Route]
}

struct Route: Decodable {
    let geometry: String
    let distance: Double
}
