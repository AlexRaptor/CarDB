//
//  Car+CoreDataProperties.swift
//  CarDB
//
//  Created by Alexander Selivanov on 18/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension Car {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Car> {
        return NSFetchRequest<Car>(entityName: "Car")
    }

    @NSManaged public var model: String?
    @NSManaged public var year: Int16
    @NSManaged public var id: Int64
    @NSManaged public var bodytype: BodyType?
    @NSManaged public var carclass: CarClass?
    @NSManaged public var manufacturer: Manufacturer?

}
