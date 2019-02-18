//
//  SettingsViewController.swift
//  CarDB
//
//  Created by Александр Селиванов on 16/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    enum ActiveSection: String {
        case brands = "manufacturer"
        case classes = "car class"
        case bodies = "body type"
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        configure()
        
        updateUI()
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
                                             values: ["name": name as! AnyObject])
                if newObject != nil { self.manufacturers.append(newObject as! Manufacturer) }

            case .classes:
                newObject = DataService.shared.addEntity(entity: CarClass.self,
                                             values: ["name": name as! AnyObject])
                if newObject != nil { self.carClasses.append(newObject as! CarClass) }

            case .bodies:
                newObject = DataService.shared.addEntity(entity: BodyType.self,
                                             values: ["name": name as! AnyObject])
                if newObject != nil { self.bodyTypes.append(newObject as! BodyType) }
            }

            if newObject != nil {
                do {
                    try DataService.shared.saveData()
                    self.tableView.reloadData()
                } catch {
                    print("Can't save data: \(error.localizedDescription)")
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
    
}
