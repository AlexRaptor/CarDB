//
//  ViewController.swift
//  CarDB
//
//  Created by Alexander Selivanov on 14/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    private var context: NSManagedObjectContext!
    private var cars = [Car]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureCoreData()

        if !isDataExists() {

            print("Data don't exists")

            buildInitialDB(from: "Cars")

        } else {
            print("Data exists")
        }

        fetchData()

        print(cars)
    }
}

// MARK: - Core Data

extension ViewController {

    private func configureCoreData() {

        let appDelegate = UIApplication.shared.delegate as! AppDelegate

        context = appDelegate.persistentContainer.viewContext
    }

    private func fetchData() {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Car")

        do {

            guard let cars = try context.fetch(request) as? [Car] else { return }

            self.cars = cars

        } catch {
            fatalError("Error fetching Cars: \(error.localizedDescription)")
        }

    }
}

// MARK: - Initial Data

extension ViewController {

    private func isDataExists() -> Bool {

        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Manufacturer")
        //request.predicate = NSPredicate(format: "name = %@", "Ford")
        request.returnsObjectsAsFaults = false
        do {

            let result = try context.fetch(request)

            if result.count > 0 { return true }

        } catch {
            fatalError("Error requesting Data: \(error.localizedDescription)")
        }

        return false
    }

    private func buildInitialDB(from plistFileName: String) {

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
                            let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: context),
                            let entityInstance = NSManagedObject(entity: entity, insertInto: context) as? T
                            else { continue }

                        entityInstance.setValue(itemName, forKey: "name")
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
                let entity = NSEntityDescription.entity(forEntityName: "Car", in: context),
                let car = NSManagedObject(entity: entity, insertInto: context) as? Car
                else { continue }

            car.setValue(manufacturer, forKey: "manufacturer")
            car.setValue(model, forKey: "model")
            car.setValue(year, forKey: "year")
            car.setValue(carClass, forKey: "carclass")
            car.setValue(bodyType, forKey: "bodytype")

            manufacturer.addToCar(car)
            carClass.addToCar(car)
            bodyType.addToCar(car)
        }

        do {
            try context.save()
        } catch {
            fatalError("Can't save initial data into context: \(error.localizedDescription)")
        }
    }
}
