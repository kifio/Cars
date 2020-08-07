//
//  CacheLifeTimeEntity+CoreDataProperties.swift
//  Cars
//
//  Created by Ivan Murashov on 07.08.2020.
//  Copyright © 2020 Ivan Murashov. All rights reserved.
//
//

import Foundation
import CoreData


extension CacheLifeTimeEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CacheLifeTimeEntity> {
        return NSFetchRequest<CacheLifeTimeEntity>(entityName: "CacheLifeTimeEntity")
    }

    @NSManaged public var insetionTimestamp: Int64

}
