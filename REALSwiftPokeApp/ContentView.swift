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
    @State private var selectedPokemon: PokemonEntry? = nil // Pokémon sélectionné pour afficher la Sheet
    @State private var isSheetPresented = false
    
    var body: some View {
        NavigationView {
            List(viewModel.pokemons) { pokemon in
                HStack {
                    AsyncImage(url: URL(string: pokemon.toPokemon().image)) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
                    
                    Text(pokemon.name.capitalized)
                        .font(.headline)
                }
                .onTapGesture {
                    selectedPokemon = pokemon
                    isSheetPresented.toggle()
                }
                .transition(.slide) // Animation de transition
            }
            .navigationTitle("Pokémon")
            .task {
                await viewModel.fetchPokemons()
            }
            .sheet(isPresented: $isSheetPresented) {
                if let selectedPokemon = selectedPokemon {
                    PokemonDetailView(pokemon: selectedPokemon)
                        .transition(.move(edge: .bottom)) // Animation lors de l'apparition de la sheet
                }
            }
        }
    }
}




