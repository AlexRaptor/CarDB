//
//  DataService.swift
//  CarDB
//
//  Created by Александр Селиванов on 16/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit
import CoreData

class DataService {
    
    static let shared = DataService()
    
    private let context: NSManagedObjectContext!
    
    // TODO: private(set)
    var cars = [Car]()
    var manufacturers = [Manufacturer]()
    var carClasses = [CarClass]()
    var bodyTypes = [BodyType]()

    private var currentID: Int64 = 0

    var nextID: Int64 {
        get {
            currentID += 1
            return currentID
        }
    }
    
    private init() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        context = appDelegate.persistentContainer.viewContext
    }
    
    func saveData() throws {
        do {
            try context.save()
        } catch {
            throw error
        }
    }
    
    func fetchCars() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        let sortByManufacturers = NSSortDescriptor(key: "manufacturer.name", ascending: true)
        let sortByModels = NSSortDescriptor(key: "model", ascending: true)
        let sortByYears = NSSortDescriptor(key: "year", ascending: false)

        request.sortDescriptors = [sortByManufacturers, sortByModels, sortByYears]
        
        do {
            
            guard let cars = try context.fetch(request) as? [Car] else { return }
            
            self.cars = cars

            for car in cars {
                if currentID < car.id { currentID = car.id }
            }
            
        } catch {
            throw error
        }
    }
    
    func fetchManufacturers() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Manufacturer")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)

        request.sortDescriptors = [sortByName]

        do {
            
            guard let manufacturers = try context.fetch(request) as? [Manufacturer] else { return }
            
            self.manufacturers = manufacturers
            
        } catch {
            throw error
        }
    }
    
    func fetchCarClasses() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarClass")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)

        request.sortDescriptors = [sortByName]

        do {
            
            guard let carClasses = try context.fetch(request) as? [CarClass] else { return }
            
            self.carClasses = carClasses
            
        } catch {
            throw error
        }
    }
    
    func fetchBodyTypes() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BodyType")
        let sortByName = NSSortDescriptor(key: "name", ascending: true)

        request.sortDescriptors = [sortByName]
        
        do {
            
            guard let bodyTypes = try context.fetch(request) as? [BodyType] else { return }
            
            self.bodyTypes = bodyTypes
            
        } catch {
            throw error
        }
    }
    
    func fetchAllData() throws {
        
        do {
            
            try fetchCars()
            try fetchManufacturers()
            try fetchCarClasses()
            try fetchBodyTypes()
            
        } catch {
            throw error
        }
    }

    func deleteCar(car: Car) throws -> Bool {

        context.delete(car)

        do {
            try saveData()
        } catch {
            throw error
        }
        
        return true
    }

    func updateCar(id: Int64, to newCar: Car) throws -> Bool {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")
        let predicate = NSPredicate(format: "id = %d", id)

        request.predicate = predicate

        do {

            guard let cars = try context.fetch(request) as? [Car] else { return false }
            guard let car = cars.first else { return false }

            if car.manufacturer != newCar.manufacturer {
                car.manufacturer?.removeFromCar(car)
                car.setValue(newCar.manufacturer, forKey: "manufacturer")
                newCar.manufacturer?.addToCar(car)
            }

            if car.carclass != newCar.carclass {
                car.carclass?.removeFromCar(car)
                car.setValue(newCar.carclass, forKey: "carclass")
                newCar.carclass?.addToCar(car)
            }

            if car.bodytype != newCar.bodytype {
                car.bodytype?.removeFromCar(car)
                car.setValue(newCar.bodytype, forKey: "bodytype")
                newCar.bodytype?.addToCar(car)
            }

            car.setValue(newCar.model, forKey: "model")
            car.setValue(newCar.year, forKey: "year")

            try saveData()

            return true

        } catch {
            throw error
        }
    }

    func removeCar(id: Int64) throws -> Bool {
        return false
    }

    func addEntity<T>(entity: T.Type, values: [String: AnyObject]) -> T? {
        
        guard
            let _ = T.self as? NSManagedObject.Type,
            let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context),
            let entityInstance = NSManagedObject(entity: entity, insertInto: context) as? T
            else { return nil }
        
        for (key, value) in values {
            (entityInstance as! NSManagedObject).setValue(value, forKey: key)
        }
        
        return entityInstance
    }
}

// MARK: - Initial Data

extension DataService {
    
    func buildInitialDB(from plistFileName: String) {
        
        func readInitialData(from plistFileName: String) -> [[String: AnyObject]] {
            
            if let path = Bundle.main.path(forResource: plistFileName, ofType: "plist") {
                
                if let dataArray = NSArray(contentsOfFile: path) as? [[String: AnyObject]] {
                    
                    return dataArray
                    
                } else {
                    fatalError("Can't read initial data into dictionary")
                }
            } else {
                fatalError("Can't find file with initial data")
            }
            
            return []
        }
        
        func getDictionaryOfCarProperties<T: NSManagedObject>
            (entity: T.Type, from dataArray: [[String: AnyObject]], key: String) -> [String: T] {
            
            var dictionary = [String: T]()
            
            for dataItem in dataArray {
                
                if let itemName = dataItem[key] as? String {
                    
                    if dictionary[itemName] == nil {
                        
                        guard
                            let entityInstance = addEntity(entity: T.self, values: ["name": itemName as AnyObject])
                            else { continue }
                        
                        dictionary.updateValue(entityInstance, forKey: itemName)
                    }
                }
            }
            
            return dictionary
        }
        
        let data = readInitialData(from: plistFileName)
        
        let manufacturers = getDictionaryOfCarProperties(entity: Manufacturer.self, from: data, key: "manufacturer")
        let carClasses = getDictionaryOfCarProperties(entity: CarClass.self, from: data, key: "class")
        let bodyTypes = getDictionaryOfCarProperties(entity: BodyType.self, from: data, key: "body")
        
        for carData in data {
            
            guard
                let manufactuterName = carData["manufacturer"] as? String,
                let model = carData["model"] as? String,
                let year = carData["year"] as? Int,
                let carClassName = carData["class"] as? String,
                let bodyTypeName = carData["body"] as? String,
                let manufacturer = manufacturers[manufactuterName],
                let carClass = carClasses[carClassName],
                let bodyType = bodyTypes[bodyTypeName],
                let car = addEntity(entity: Car.self, values: [
                    "id": nextID as AnyObject,
                    "manufacturer": manufacturer,
                    "model": model as AnyObject,
                    "year": year as AnyObject,
                    "carclass": carClass,
                    "bodytype": bodyType
                    ])
                else { continue }
            
            manufacturer.addToCar(car)
            carClass.addToCar(car)
            bodyType.addToCar(car)
        }
        
        do {
            try saveData()
        } catch {
            fatalError("Can't save initial data into context: \(error.localizedDescription)")
        }
    }
}
