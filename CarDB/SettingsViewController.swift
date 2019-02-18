//
//  SettingsViewController.swift
//  CarDB
//
//  Created by Александр Селиванов on 16/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit

enum ActiveSection: String {
    case brands = "manufacturer"
    case classes = "car class"
    case bodies = "body type"
}

class SettingsViewController: UIViewController {

    @IBOutlet weak var brandsButton: UIBarButtonItem!
    @IBOutlet weak var classesButton: UIBarButtonItem!
    @IBOutlet weak var bodiesButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    
    private var activeSection = ActiveSection.brands
    private var activeButtonColor: UIColor?
    private var inactiveButtonColor = UIColor.gray
    
    var manufacturers = [Manufacturer]()
    var carClasses = [CarClass]()
    var bodyTypes = [BodyType]()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            try DataService.shared.fetchManufacturers()
            manufacturers = DataService.shared.manufacturers
        } catch {
            print("Can't fetch manufacturers: \(error.localizedDescription)")
        }

        do {
            try DataService.shared.fetchCarClasses()
            carClasses = DataService.shared.carClasses
        } catch {
            print("Can't fetch car classes: \(error.localizedDescription)")
        }

        do {
            try DataService.shared.fetchBodyTypes()
            bodyTypes = DataService.shared.bodyTypes
        } catch {
            print("Can't body types : \(error.localizedDescription)")
        }

        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        configure()
    }

    fileprivate func  configure() {
        activeButtonColor = brandsButton.tintColor
    }
    
    fileprivate func updateUI() {
        
        switch activeSection {
            
        case .brands:
            
            brandsButton.tintColor = activeButtonColor
            classesButton.tintColor = inactiveButtonColor
            bodiesButton.tintColor = inactiveButtonColor
            title = "Brands"
            
        case .classes:
            
            brandsButton.tintColor = inactiveButtonColor
            classesButton.tintColor = activeButtonColor
            bodiesButton.tintColor = inactiveButtonColor
            title = "Classes"
            
        case .bodies:
            
            brandsButton.tintColor = inactiveButtonColor
            classesButton.tintColor = inactiveButtonColor
            bodiesButton.tintColor = activeButtonColor
            title = "Bodies"
        }
        
        tableView.reloadData()
    }
    
    @IBAction func brandsButtonTapped(_ sender: Any) {
        activeSection = .brands
        updateUI()
    }
    
    @IBAction func classesButtonTapped(_ sender: Any) {
        activeSection = .classes
        updateUI()
    }
    
    @IBAction func bodiesButtonTapped(_ sender: Any) {
        activeSection = .bodies
        updateUI()
    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Add", message: "Enter a \(activeSection.rawValue) name", preferredStyle: .alert)
        alert.addTextField()
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            
            let name = alert.textFields![0].text ?? "none"
            var newObject: AnyObject?

            switch self.activeSection {

            case .brands:
                newObject = DataService.shared.addEntity(entity: Manufacturer.self,
                                                         values: ["name": name as AnyObject])
            case .classes:
                newObject = DataService.shared.addEntity(entity: CarClass.self,
                                                         values: ["name": name as AnyObject])

            case .bodies:
                newObject = DataService.shared.addEntity(entity: BodyType.self,
                                                         values: ["name": name as AnyObject])
            }

            if newObject != nil {
                do {
                    try DataService.shared.saveData()
                } catch {
                    print("Can't save data: \(error.localizedDescription)")
                }

                do {
                    switch self.activeSection {

                    case .brands:
                        try DataService.shared.fetchManufacturers()
                        self.manufacturers = DataService.shared.manufacturers

                    case .classes:
                        try DataService.shared.fetchCarClasses()
                        self.carClasses = DataService.shared.carClasses

                    case .bodies:
                        try DataService.shared.fetchBodyTypes()
                        self.bodyTypes = DataService.shared.bodyTypes
                    }

                    self.tableView.reloadData()

                } catch {
                    print("Can't fetch data: \(error.localizedDescription)")
                }
            }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alert.addAction(cancelAction)
        alert.addAction(okAction)

        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Table view data source methods

extension SettingsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch activeSection {

        case .brands:
            return manufacturers.count
            
        case .classes :
            return carClasses.count
            
        case .bodies:
            return bodyTypes.count
        }
    }
    
    fileprivate func getEntityInfo(forIndex index: Int) -> String {

        switch activeSection {
            
        case .brands:
            return manufacturers[index].name ?? ""
            
        case .classes :
            return carClasses[index].name ?? ""
            
        case .bodies:
            return bodyTypes[index].name ?? ""
        }
    }    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = getEntityInfo(forIndex: indexPath.row)
        
        return cell
    }
}

// MARK: - Table view delegate methods

extension SettingsViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
