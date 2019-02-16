//
//  SettingsViewController.swift
//  CarDB
//
//  Created by Александр Селиванов on 16/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    enum ActiveSection {
        case brands, classes, bodies
    }
    
    @IBOutlet weak var brandsButton: UIBarButtonItem!
    @IBOutlet weak var classesButton: UIBarButtonItem!
    @IBOutlet weak var bodiesButton: UIBarButtonItem!

    @IBOutlet weak var tableView: UITableView!
    
    private var activeSection = ActiveSection.brands
    private var activeButtonColor: UIColor?
    private var inactiveButtonColor = UIColor.gray
    
    private var manufacturers = [Manufacturer]()
    private var carClasses = [CarClass]()
    private var bodyTypes = [BodyType]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        configure()
        
        updateToolBar()
    }

    fileprivate func  configure() {
        activeButtonColor = brandsButton.tintColor
    }
    
    fileprivate func updateToolBar() {
        
        switch activeSection {
            
        case .brands:
            
            brandsButton.tintColor = activeButtonColor
            classesButton.tintColor = inactiveButtonColor
            bodiesButton.tintColor = inactiveButtonColor
            
        case .classes:
            
            brandsButton.tintColor = inactiveButtonColor
            classesButton.tintColor = activeButtonColor
            bodiesButton.tintColor = inactiveButtonColor
            
        case .bodies:
            
            brandsButton.tintColor = inactiveButtonColor
            classesButton.tintColor = inactiveButtonColor
            bodiesButton.tintColor = activeButtonColor
        }
        
        tableView.reloadData()
    }
    
    @IBAction func brandsButtonTapped(_ sender: Any) {
        activeSection = .brands
        updateToolBar()
    }
    
    @IBAction func classesButtonTapped(_ sender: Any) {
        activeSection = .classes
        updateToolBar()
    }
    
    @IBAction func bodiesButtonTapped(_ sender: Any) {
        activeSection = .bodies
        updateToolBar()
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
