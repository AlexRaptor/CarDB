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
        
        do {
            
            guard let cars = try context.fetch(request) as? [Car] else { return }
            
            self.cars = cars
            
        } catch {
            throw error
        }
    }
    
    func fetchManufacturers() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Manufacturer")
        
        do {
            
            guard let manufacturers = try context.fetch(request) as? [Manufacturer] else { return }
            
            self.manufacturers = manufacturers
            
        } catch {
            throw error
        }
    }
    
    func fetchCarClasses() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CarClass")
        
        do {
            
            guard let carClasses = try context.fetch(request) as? [CarClass] else { return }
            
            self.carClasses = carClasses
            
        } catch {
            throw error
        }
    }
    
    func fetchBodyTypes() throws {
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "BodyType")
        
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
                            let entityInstance = addEntity(entity: T.self, values: ["name": itemName as! AnyObject])
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
                    "manufacturer": manufacturer,
                    "model": model as! AnyObject,
                    "year": year as! AnyObject,
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
