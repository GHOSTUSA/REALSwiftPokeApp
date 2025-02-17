//
//  Pokemon.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import SwiftUI
import CoreData

struct Pokemon {
    let id: Int
    let name: String
    let image: String
    let types: String // Rend les types optionnels
    let stats: Stats
}


struct Stats {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
}
