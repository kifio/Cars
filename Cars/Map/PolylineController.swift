//
//  PolylineController.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import Foundation
import Mapbox

class PolyLineController {
    
    struct Constants {
        static let polyline = "polyline"
        static let round = "round"
        static let timeInterval = 0.02
    }
    
    private var timer: Timer?
    private var polylineSource: MGLShapeSource?
    private var currentIndex: Int = 1
    
    var lineCoordinates: [CLLocationCoordinate2D]!

    func addPolyline(to style: MGLStyle) {
        
        if polylineSource == nil {
            let source = MGLShapeSource(identifier: Constants.polyline, shape: nil, options: nil)
            style.addSource(source)
            polylineSource = source
        }
        
        if style.layer(withIdentifier: Constants.polyline) == nil, let source = polylineSource {
            let layer = MGLLineStyleLayer(identifier: Constants.polyline, source: source)
            layer.lineJoin = NSExpression(forConstantValue: Constants.round)
            layer.lineCap = NSExpression(forConstantValue: Constants.round)
            layer.lineColor = NSExpression(forConstantValue: UIColor.red)
            layer.lineWidth = NSExpression(format: "mgl_interpolate:withCurveType:parameters:stops:($zoomLevel, 'linear', nil, %@)",
                                           [14: 5, 18: 20])
            style.addLayer(layer)
        }
    }
    
    func animatePolyline() {
        currentIndex = 1
        timer = Timer.scheduledTimer(timeInterval: Constants.timeInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if currentIndex > lineCoordinates.count {
            timer?.invalidate()
            timer = nil
            return
        }
        
        updatePolylineWithCoordinates(coordinates: Array(lineCoordinates[0..<currentIndex]))
        currentIndex += 1
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        polylineSource?.shape = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
    }
}
