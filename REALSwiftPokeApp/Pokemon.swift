//
//  Pokemon.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import SwiftUI
import CoreData

struct Pokemon: Identifiable, Equatable {
    var id: Int
    var name: String
    var image: String
    var types: String // ou un tableau de chaînes, si tu préfères
    var stats: Stats
    
    static func ==(lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.image == rhs.image &&
               lhs.types == rhs.types &&
               lhs.stats == rhs.stats
    }
}



struct Stats: Equatable {
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
}
