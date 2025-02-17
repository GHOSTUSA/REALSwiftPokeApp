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
                    // Afficher l'image du Pokémon
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
                    selectedPokemon = pokemon // Mettre à jour le Pokémon sélectionné
                    Task {
                        await viewModel.fetchPokemonDetails(for: pokemon) // Récupérer les détails à partir de l'URL
                    }
                    isSheetPresented.toggle() // Afficher la Sheet
                }
            }
            .navigationTitle("Pokémon")
            .task {
                await viewModel.fetchPokemons()
            }
            .sheet(isPresented: $isSheetPresented) {
                if let selectedPokemon = viewModel.selectedPokemon {
                    PokemonDetailView(pokemon: selectedPokemon) // Passer le Pokémon sélectionné à la Sheet
                }
            }
        }
    }
}



