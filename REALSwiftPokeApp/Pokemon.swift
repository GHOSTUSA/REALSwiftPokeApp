//
//  Pokemon.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import SwiftUI

struct Pokemon: Identifiable {
    let id = UUID()
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

// Exemple de Pokémon
let pikachu = Pokemon(
    name: "Pikachu",
    image: "pikachu", // Suppose que l'image s'appelle "pikachu" dans les assets
    types: ["Électrique"],
    stats: Stats(hp: 35, attack: 55, defense: 40, speed: 90)
)
