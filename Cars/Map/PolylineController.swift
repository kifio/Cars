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
    
    var lineCoordinates: [CLLocationCoordinate2D]?
    
    func clear(_ style: MGLStyle) {
        self.lineCoordinates?.removeAll()
        self.polylineSource?.shape = nil
    }
    
    func addPolyline(_ lineCoordinates: [CLLocationCoordinate2D], to style: MGLStyle) {
        
        self.lineCoordinates = lineCoordinates

        if polylineSource == nil {
            let source = MGLShapeSource(identifier: Constants.polyline, shape: nil, options: nil)
            style.addSource(source)
            self.polylineSource = source
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
        self.currentIndex = 1
        self.timer = Timer.scheduledTimer(timeInterval: Constants.timeInterval, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    @objc func tick() {
        if let lineCoordinates = self.lineCoordinates, currentIndex <= lineCoordinates.count {
            self.updatePolylineWithCoordinates(coordinates: Array(lineCoordinates[0..<currentIndex]))
            self.currentIndex += 1
        } else {
            self.timer?.invalidate()
            self.timer = nil
            return
        }
    }
    
    func updatePolylineWithCoordinates(coordinates: [CLLocationCoordinate2D]) {
        var mutableCoordinates = coordinates
        self.polylineSource?.shape = MGLPolylineFeature(coordinates: &mutableCoordinates, count: UInt(mutableCoordinates.count))
    }
}
