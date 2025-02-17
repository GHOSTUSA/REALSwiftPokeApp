//
//  Pokemon.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import SwiftUI
import CoreData

struct Pokemon: Identifiable {
    let id : Int
    let name: String
    let image: String // Nom de l'image dans les assets ou URL
    let types: [String] // Un Pokémon peut avoir plusieurs types
    let stats: Stats // Structure pour les statistiques principales
}

struct Stats {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
}
