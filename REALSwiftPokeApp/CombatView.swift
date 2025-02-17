//
//  CombatView.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import SwiftUI
import CoreData

struct CombatView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var selectedPokemon: Pokemon? = nil
    @State private var randomOpponent: Pokemon? = nil
    @State private var combatResult: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                if let selectedPokemon = selectedPokemon {
                    // Affichage du Pokémon sélectionné
                    Text("Votre Pokémon : \(selectedPokemon.name.capitalized)")
                        .font(.title)
                        .padding()
                    
                    // Bouton pour lancer le combat
                    Button("Lancer le combat") {
                        startCombat()
                    }
                    .padding()
                    
                    // Affichage du résultat du combat
                    if !combatResult.isEmpty {
                        Text(combatResult)
                            .font(.headline)
                            .padding()
                    }
                } else {
                    // Choisir un Pokémon avant de commencer
                    Text("Choisissez un Pokémon pour commencer")
                        .font(.title)
                        .padding()
                }
                
                // Liste des Pokémon à choisir
                List(viewModel.pokemons, id: \.id) { pokemon in
                    Text(pokemon.name.capitalized)
                        .onTapGesture {
                            selectedPokemon = pokemon
                        }
                }
                
                // Affichage du Pokémon aléatoire dans le combat
                if let randomOpponent = randomOpponent {
                    Text("Adversaire : \(randomOpponent.name.capitalized)")
                        .font(.title2)
                        .padding()
                    
                    // Afficher l'image de l'adversaire
                    AsyncImage(url: URL(string: randomOpponent.image)) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 100, height: 100)
                    } placeholder: {
                        ProgressView()
                    }
                    .padding()
                }
            }
            .navigationTitle("Mode Combat")
            .onAppear {
                Task {
                    await viewModel.fetchPokemonsWithDetails()
                }
            }
        }
    }
    
    // Fonction de combat
    private func startCombat() {
        guard let selectedPokemon = selectedPokemon else { return }
        
        // Sélectionner un adversaire aléatoire
        randomOpponent = viewModel.pokemons.randomElement()
        
        // Calculer le gagnant en fonction des stats
        if let opponent = randomOpponent {
            let winner = battleResult(player: selectedPokemon, opponent: opponent)
            combatResult = "\(winner.name) gagne !"
        }
    }
    
    // Comparer les stats des Pokémon pour déterminer le gagnant
    private func battleResult(player: Pokemon, opponent: Pokemon) -> Pokemon {
        let playerScore = player.stats.hp + player.stats.attack + player.stats.defense + player.stats.speed
        let opponentScore = opponent.stats.hp + opponent.stats.attack + opponent.stats.defense + opponent.stats.speed
        
        return playerScore > opponentScore ? player : opponent
    }
}
