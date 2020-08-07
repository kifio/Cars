//
//  Cacahe.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//

import CoreData

class Cache {
    lazy var coreDataStack = CoreDataStack()
    
    func updateAndFetch(cars: [Car], _ onCarsFetched: ([Car]) -> ()) {
        self.clearCache()
        self.updateCacheInsertingDate()
        self.updateCache(cars)
        onCarsFetched(cars)
    }
    
    func fetch(_ onCarsFetched: ([Car]) -> ()) {
        guard isCacheStillValid(insertionTimestamp: getCacheInsertionDate()) else {
            onCarsFetched([Car]())
            return
        }
        
        do {
            let fetchRequest: NSFetchRequest<CarEntity> = CarEntity.fetchRequest()
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            onCarsFetched(results.map {
                $0.toCar()
            })
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    private func clearCache() {
        do {
            try coreDataStack.managedContext.execute(NSBatchDeleteRequest(fetchRequest: CarEntity.fetchRequest()))
            
            try coreDataStack.managedContext.execute(NSBatchDeleteRequest(fetchRequest: CacheLifeTimeEntity.fetchRequest()))
            
        } catch let err {
            print(err.localizedDescription)
        }
    }
    
    private func updateCache(_ cars: [Car]) {
        for car in cars {
            let entity = NSEntityDescription.entity(
                forEntityName: "CarEntity",
                in: coreDataStack.managedContext)!
            
            let carEntity = CarEntity(entity: entity,
                                      insertInto: coreDataStack.managedContext)
            
            carEntity.fillWith(car: car)
        }
        try! coreDataStack.managedContext.save()
    }
    
    private func updateCacheInsertingDate() {
        let entity = NSEntityDescription.entity(
            forEntityName: "CacheLifeTimeEntity",
            in: coreDataStack.managedContext)!
        
        let cacheLifetimeEnity = CacheLifeTimeEntity(entity: entity,
                                           insertInto: coreDataStack.managedContext)
        cacheLifetimeEnity.insetionTimestamp = Int64(Date().timeIntervalSince1970)
        try! coreDataStack.managedContext.save()
    }
    
    private func getCacheInsertionDate() -> Double? {
        let fetchRequest: NSFetchRequest<CacheLifeTimeEntity> = CacheLifeTimeEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        guard let results = try? coreDataStack.managedContext.fetch(fetchRequest),
            let insertionTimestamp = results.first?.insetionTimestamp else {
                return nil
        }
        
        return Double(insertionTimestamp)
    }
    
    private func isCacheStillValid(insertionTimestamp: Double?) -> Bool {
        guard let insertionTimestamp = insertionTimestamp else {
            return false
        }
        return Date().timeIntervalSince1970 - insertionTimestamp < 3600
    }
}

extension CarEntity {
    fileprivate func toCar() -> Car {
        return
            Car(
                id: Int(self.id),
                plateNumber: self.plateNumber,
                name: self.name,
                color: self.color,
                angle: Int(self.angle),
                fuelPercentage: Int(self.fuelPercntage),
                latitude: self.latitude,
                longitude: self.longitude
        )
    }
    
    fileprivate func fillWith(car: Car) {
        self.id = Int32(car.id)
        self.plateNumber = car.plateNumber
        self.name = car.name
        self.color = car.color
        self.angle = Int16(car.angle)
        self.fuelPercntage = Int16(car.fuelPercentage)
        self.latitude = car.latitude
        self.longitude = car.longitude
    }
}
