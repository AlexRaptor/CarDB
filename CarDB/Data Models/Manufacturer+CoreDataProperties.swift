//
//  Manufacturer+CoreDataProperties.swift
//  CarDB
//
//  Created by Alexander Selivanov on 14/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//
//

import Foundation
import CoreData


extension Manufacturer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Manufacturer> {
        return NSFetchRequest<Manufacturer>(entityName: "Manufacturer")
    }

    @NSManaged public var name: String?
    @NSManaged public var car: NSSet?

}

// MARK: Generated accessors for car
extension Manufacturer {

    @objc(addCarObject:)
    @NSManaged public func addToCar(_ value: Car)

    @objc(removeCarObject:)
    @NSManaged public func removeFromCar(_ value: Car)

    @objc(addCar:)
    @NSManaged public func addToCar(_ values: NSSet)

    @objc(removeCar:)
    @NSManaged public func removeFromCar(_ values: NSSet)

}
