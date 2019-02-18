//
//  ViewController.swift
//  CarDB
//
//  Created by Alexander Selivanov on 14/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit
import CoreData

class CarTableViewController: UITableViewController, CarEditingDelegate {

    internal var cars = [Car]()
    private var selectedIndex = 0

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        do {
            try DataService.shared.fetchCars()
        } catch {
            fatalError("Error fetching data: \(error.localizedDescription)")
        }

        cars = DataService.shared.cars

        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        
        // если в БД нет ни одного производителя, будем считать,
        // что это первый запуск
        // можно конечно хранить инфу про первый запуск в UserDefaults,
        // но забьёи на это
        do {
            try DataService.shared.fetchManufacturers()
        } catch {
            fatalError("Error fetching manufacturers data: \(error.localizedDescription)")
        }
        
        if DataService.shared.manufacturers.count == 0 {

            print("Data don't exists")
            DataService.shared.buildInitialDB(from: "Cars")
            
        } else {
            print("Data exists")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        /*
        if segue.identifier == "ShowSettings" {
            
            let settingsViewController = segue.destination as! SettingsViewController
            
            settingsViewController.manufacturers = DataService.shared.manufacturers
            settingsViewController.carClasses = DataService.shared.carClasses
            settingsViewController.bodyTypes = DataService.shared.bodyTypes
        } else */
            if segue.identifier == "AddCar" {

            let carViewController = segue.destination as! CarViewController

            carViewController.viewTitle = "Add Car"
            carViewController.operationType = .add

        } else if segue.identifier == "EditCar" {

            let carViewController = segue.destination as! CarViewController

            carViewController.viewTitle = "Edit Car"
            carViewController.operationType = .edit

            let car = cars[selectedIndex]

            carViewController.car = car
            carViewController.manufacturer = car.manufacturer
            carViewController.carClass = car.carclass
            carViewController.bodyType = car.bodytype


            carViewController.model = car.model
            carViewController.year = car.year
        }
    }
    
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ShowSettings", sender: self)
    }

    @IBAction func addTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "AddCar", sender: self)
    }

    func carDidAdded(car: Car) {
        carDidEditing(car: car)
    }

    func carDidEditing(car: Car) {

        do {
            try DataService.shared.fetchCars()
            cars = DataService.shared.cars
            tableView.reloadData()
        } catch {
            print("Can't fetch cars: \(error.localizedDescription))")
        }

        tableView.reloadData()
    }
}

// MARK: - Table view data source methods

extension CarTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cars.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CarCell", for: indexPath) as! CarTableViewCell

        let car = cars[indexPath.row]
        cell.manufacturerLabel.text = car.manufacturer?.name
        cell.modelLabel.text = car.model
        cell.yearLabel.text = "\(car.year)"
        cell.carClassLabel.text = "\(car.carclass?.name ?? "unknown")"
        cell.bodyTypeLabel.text = "\(car.bodytype?.name ?? "unknown")"

        return cell
    }
}

// MARK: - Table view delegate methods

extension CarTableViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        selectedIndex = indexPath.row

        print(cars[selectedIndex])

        tableView.deselectRow(at: indexPath, animated: true)

        performSegue(withIdentifier: "EditCar", sender: self)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {

            do {
                let _ = try DataService.shared.deleteCar(car: cars[indexPath.row])
                cars.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Unable to delete: \(error.localizedDescription)")
            }
        }
    }
}
