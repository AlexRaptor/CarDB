//
//  ViewController.swift
//  CarDB
//
//  Created by Alexander Selivanov on 14/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit
import CoreData

class CarTableViewController: UITableViewController {

    private var cars = [Car]()
    
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

        do {
            try DataService.shared.fetchAllData()
        } catch {
            fatalError("Error fetching data: \(error.localizedDescription)")
        }
        
        cars = DataService.shared.cars
        
        tableView.reloadData()

        print(cars)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowSettings" {
            
            let settingsViewController = segue.destination as! SettingsViewController
            
            settingsViewController.manufacturers = DataService.shared.manufacturers
            settingsViewController.carClasses = DataService.shared.carClasses
            settingsViewController.bodyTypes = DataService.shared.bodyTypes
        }
    }
    
    @IBAction func settingsTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "ShowSettings", sender: self)
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

        let car = cars[indexPath.row]

        print(car)

        tableView.deselectRow(at: indexPath, animated: true)
    }
}
