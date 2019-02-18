//
//  CarPropertiesTableViewController.swift
//  CarDB
//
//  Created by Alexander Selivanov on 18/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit

protocol CarPropertyChoseDelegate {

    func manufacturerChose(value: Manufacturer)
    func classChose(value: CarClass)
    func bodyChose(value: BodyType)
}

class CarPropertiesTableViewController: UITableViewController {

    var delegate: CarPropertyChoseDelegate?

    var activeSection = ActiveSection.brands

    var manufacturers = [Manufacturer]()
    var carClasses = [CarClass]()
    var bodyTypes = [BodyType]()

    var currentName: String?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        switch activeSection {

        case .brands:
            title = "Manufacturers"

            do {
                try DataService.shared.fetchManufacturers()
                manufacturers = DataService.shared.manufacturers
            } catch {
                print("Can't fetch manufacturers: \(error.localizedDescription)")
            }

        case .classes :
            title = "Classes"

            do {
                try DataService.shared.fetchCarClasses()
                carClasses = DataService.shared.carClasses
            } catch {
                print("Can't fetch car classes: \(error.localizedDescription)")
            }

        case .bodies:
            title = "Bodies"

            do {
                try DataService.shared.fetchBodyTypes()
                bodyTypes = DataService.shared.bodyTypes
            } catch {
                print("Can't fetch body types: \(error.localizedDescription)")
            }
        }

        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch activeSection {

        case .brands:
            return manufacturers.count

        case .classes :
            return carClasses.count

        case .bodies:
            return bodyTypes.count
        }
    }

    private func getEntityInfo(forIndex index: Int) -> String {

        switch activeSection {

        case .brands:
            return manufacturers[index].name ?? ""

        case .classes :
            return carClasses[index].name ?? ""

        case .bodies:
            return bodyTypes[index].name ?? ""
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PropertyCell", for: indexPath)

        let cellText = getEntityInfo(forIndex: indexPath.row)

        cell.textLabel?.text = cellText

        if currentName != nil && cellText == currentName! {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        guard let delegate = delegate else { return }

        switch activeSection {

        case .brands:
            delegate.manufacturerChose(value: manufacturers[indexPath.row])

        case .classes :
            delegate.classChose(value: carClasses[indexPath.row])

        case .bodies:
            delegate.bodyChose(value: bodyTypes[indexPath.row])
        }

        currentName = getEntityInfo(forIndex: indexPath.row)

        tableView.reloadData()
    }
}
