//
//  PersistenceController.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "REALSwiftPokeApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Erreur de chargement de Core Data: \(error)")
            }
        }
    }
}
