//
//  ContentView.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import SwiftUI
import CoreData

struct PokemonEntry: Codable, Identifiable {
    var id: Int {
        Int(url.split(separator: "/").last ?? "0") ?? 0
    }
    let name: String
    let url: String
    
    func toPokemon() -> Pokemon {
        return Pokemon(
            id: id,
            name: name.capitalized,
            image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png",
            types: [],
            stats: Stats(hp: 0, attack: 0, defense: 0, speed: 0)
        )
    }
}

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.pokemons.map { $0.toPokemon() }) { pokemon in
                HStack {
                    AsyncImage(url: URL(string: pokemon.image)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    Text(pokemon.name)
                        .font(.headline)
                }
            }
            .navigationTitle("Pokémon")
            .task {
                await viewModel.fetchPokemons()
            }
        }
    }
}
