//
//  Car+Extensions.swift
//  CarDB
//
//  Created by Alexander Selivanov on 15/02/2019.
//  Copyright © 2019 Alexander Selivanov. All rights reserved.
//

//import Foundation

extension Car {

    public override var description: String {
        return """
        { ID: \(self.id), \
        Manufacturer: \(self.manufacturer?.name ?? "none"), \
        Model: \(self.model ?? "none"), \
        Year: \(self.year), \
        Class: \(self.carclass?.name ?? "none"), \
        Body: \(self.bodytype?.name ?? "none") }
        """
    }
}
