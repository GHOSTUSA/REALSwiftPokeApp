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
    var types: String
    var stats: Stats
    var isFavorite: Bool
    
    static func ==(lhs: Pokemon, rhs: Pokemon) -> Bool {
        return lhs.id == rhs.id &&
               lhs.name == rhs.name &&
               lhs.image == rhs.image &&
               lhs.types == rhs.types &&
               lhs.stats == rhs.stats &&
        lhs.isFavorite == rhs.isFavorite
    }
}



struct Stats: Equatable {
    let hp: Int64
    let attack: Int64
    let defense: Int64
    let speed: Int64
}
