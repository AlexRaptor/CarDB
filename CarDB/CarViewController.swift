//
//  CarViewController.swift
//  CarDB
//
//  Created by Alexander Selivanov on 18/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

import UIKit

protocol CarEditingDelegate {

    var cars: [Car] { get set }
    func carDidAdded(car: Car)
    func carDidEditing(car: Car)
}

enum OperationType {
    case edit, add
}

class CarViewController: UIViewController {

    var delegate: CarEditingDelegate?
    var operationType = OperationType.add

    @IBOutlet weak var manufacturerButton: UIButton!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var yearTextField: UITextField!
    @IBOutlet weak var classButton: UIButton!
    @IBOutlet weak var bodyButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!

    var viewTitle: String?

    var car: Car?
    var manufacturer: Manufacturer?
    var carClass: CarClass?
    var bodyType: BodyType?
    var model: String?
    var year: Int16?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.title = viewTitle
        updateUI()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)

        modelTextField.delegate = self
    }

    @objc func dismissKeyboard() {

        view.endEditing(true)

        updateUI()
    }

    private func updateUI() {

        if car == nil {
            manufacturerButton.setTitle("Click here", for: .normal)
            classButton.setTitle("Click here", for: .normal)
            bodyButton.setTitle("Click here", for: .normal)
        }

        if manufacturer != nil {
            manufacturerButton.setTitle(manufacturer?.name, for: .normal)
        }

        if carClass != nil {
            classButton.setTitle(carClass?.name, for: .normal)
        }

        if bodyType != nil {
            bodyButton.setTitle(bodyType?.name, for: .normal)
        }

        saveButton.isEnabled = checkData()

        modelTextField.text = model

        guard let year = year else { return }

        yearTextField.text = String(year)
    }

    private func checkData() -> Bool {

        return !(manufacturer == nil
            || carClass == nil
            || bodyType == nil
            || model == nil
            || year == nil)
    }

    @IBAction func manufacturerTapped(_ sender: UIButton) {

        performSegue(withIdentifier: "ChoseManufacturer", sender: self)
        updateUI()
    }

    @IBAction func classTapped(_ sender: UIButton) {

        performSegue(withIdentifier: "ChoseClass", sender: self)
        updateUI()
    }

    @IBAction func bodyTapped(_ sender: UIButton) {

        performSegue(withIdentifier: "ChoseBody", sender: self)
        updateUI()
    }

    @IBAction func modelChanged(_ sender: UITextField) {

        model = sender.text

        updateUI()
    }

    @IBAction func yearChanged(_ sender: UITextField) {

        guard let text = sender.text else { return }

        year = Int16(text)

        updateUI()
    }

    private func createNewCar() {

        guard
            let manufacturer = manufacturer,
            let carClass = carClass,
            let bodyType = bodyType,
            let car = DataService.shared.addEntity(entity: Car.self, values: [
                "id": DataService.shared.nextID as AnyObject,
                "manufacturer": manufacturer,
                "model": model as AnyObject,
                "year": year as AnyObject,
                "carclass": carClass,
                "bodytype": bodyType
                ])
            else { return }

        manufacturer.addToCar(car)
        carClass.addToCar(car)
        bodyType.addToCar(car)

        do {
            try DataService.shared.saveData()
            guard let delegate = delegate else { return }
            delegate.carDidAdded(car: car)
        } catch {
            print("Error saved new car: \(error.localizedDescription)")
        }
    }

    private func editCar() {

        guard
            let manufacturer = manufacturer,
            let carClass = carClass,
            let bodyType = bodyType,
            let model = model,
            let year = year,
            let car = car
            else { return }

        car.manufacturer = manufacturer
        car.carclass = carClass
        car.bodytype = bodyType
        car.model = model
        car.year = year

        do {
            if try DataService.shared.updateCar(id: car.id, to: car) {
                guard let delegate = delegate else { return }
                delegate.carDidAdded(car: car)
            }
        } catch {
            print("Error saved edited car: \(error.localizedDescription)")
        }
    }

    @IBAction func saveTapped(_ sender: UIButton) {

        switch operationType {

        case .add:
            createNewCar()

        case .edit:
            editCar()
        }

        navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension CarViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()

        updateUI()

        return true
    }
}

// MARK: - CarPropertyChoseDelegate

extension CarViewController: CarPropertyChoseDelegate {

    func manufacturerChose(value: Manufacturer) {
        manufacturer = value
    }

    func classChose(value: CarClass) {
        carClass = value
    }

    func bodyChose(value: BodyType) {
        bodyType = value
    }
}

// MARK: - Segues

extension CarViewController {

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        let propertyViewController = segue.destination as! CarPropertiesTableViewController

        propertyViewController.delegate = self

        switch segue.identifier {

        case "ChoseManufacturer":
            propertyViewController.activeSection = .brands
            propertyViewController.currentName = manufacturer?.name

        case "ChoseClass":
            propertyViewController.activeSection = .classes
            propertyViewController.currentName = carClass?.name

        case "ChoseBody":
            propertyViewController.activeSection = .bodies
            propertyViewController.currentName = bodyType?.name

        default: break
        }
    }
}
