//
//  filteredAndSortedPokemons.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import CoreData
import SwiftUI

var filteredAndSortedPokemons: [PokemonEntry] {
    var filteredPokemons = PokemonViewModel.pokemons // Utilisation de l'instance viewModel
    
    // Filtrer par nom
    if !searchText.isEmpty {
        filteredPokemons = filteredPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    
    // Filtrer par type
    if let selectedType = selectedType {
        filteredPokemons = filteredPokemons.filter { pokemon in
            // Vérifier si le Pokémon a le type sélectionné dans sa liste de types
            pokemon.toPokemon().types.contains(selectedType)
        }
    }
    
    // Trier
    switch sortOption {
    case .alphabetical:
        filteredPokemons.sort { $0.name.lowercased() < $1.name.lowercased() }
    case .attack:
        filteredPokemons.sort { $0.toPokemon().stats.attack > $1.toPokemon().stats.attack }
    case .defense:
        filteredPokemons.sort { $0.toPokemon().stats.defense > $1.toPokemon().stats.defense }
    case .speed:
        filteredPokemons.sort { $0.toPokemon().stats.speed > $1.toPokemon().stats.speed }
    }
    
    return filteredPokemons
}

