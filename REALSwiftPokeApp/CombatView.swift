import CoreData
import SwiftUI

struct CombatView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var selectedPokemon: Pokemon? = nil
    @State private var randomOpponent: Pokemon? = nil
    @State private var combatResult: String = ""
    @State private var showFavoritesOnly: Bool = false  // Pour afficher uniquement les favoris
    
    var body: some View {
        NavigationView {
            VStack {
                // Affichage des Pokémon sélectionnés et de l'adversaire
                VStack {
                    if let selectedPokemon = selectedPokemon {
                        HStack {
                            Text("Votre Pokémon : ")
                                .font(.body)
                            Text(selectedPokemon.name.capitalized)
                                .font(.title)
                        }
                    }
                    
                    if let randomOpponent = randomOpponent {
                        Text("Adversaire : \(randomOpponent.name.capitalized)")
                            .font(.title2)
                            .padding()
                        
                        AsyncImage(url: URL(string: randomOpponent.image)) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .padding()
                
                // Liste des Pokémon à choisir, avec option de filtrer par favoris
                VStack {
                    Toggle(isOn: $showFavoritesOnly) {
                        Text("Afficher les favoris uniquement")
                    }
                    .padding()
                    
                    List(filteredPokemons, id: \.id) { pokemon in
                        HStack {
                            Text(pokemon.name.capitalized)
                            Spacer()
                            Button(action: {
                                toggleFavorite(pokemon: pokemon)
                            }) {
                                Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(pokemon.isFavorite ? .red : .gray)
                            }
                            .buttonStyle(PlainButtonStyle()) // Désactive l'effet du bouton pour éviter la propagation du geste
                        }
                        .contentShape(Rectangle()) // Agrandit la zone tactile du HStack sans inclure le bouton
                        .onTapGesture {
                            selectedPokemon = pokemon
                        }
                    }
                }
                
                // Affichage du résultat du combat et bouton pour lancer
                Spacer()
                if !combatResult.isEmpty {
                    Text(combatResult)
                        .font(.headline)
                        .padding()
                }
                
                if selectedPokemon != nil {
                    Button("Lancer le combat") {
                        startCombat()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .onAppear {
                Task {
                    await viewModel.fetchPokemonsWithDetails()
                }
            }
        }
    }
    
    private var filteredPokemons: [Pokemon] {
        if showFavoritesOnly {
            return viewModel.pokemons.filter { $0.isFavorite }
        } else {
            return viewModel.pokemons
        }
    }
    
    private func toggleFavorite(pokemon: Pokemon) {
        viewModel.toggleFavorite(pokemon: pokemon)
    }

    
    private func startCombat() {
        guard let selectedPokemon = selectedPokemon else { return }
        randomOpponent = viewModel.pokemons.randomElement()
        
        if let opponent = randomOpponent {
            let winner = battleResult(player: selectedPokemon, opponent: opponent)
            combatResult = "\(winner.name) gagne !"
        }
    }
    
    private func battleResult(player: Pokemon, opponent: Pokemon) -> Pokemon {
        let playerScore = player.stats.hp + player.stats.attack + player.stats.defense + player.stats.speed
        let opponentScore = opponent.stats.hp + opponent.stats.attack + opponent.stats.defense + opponent.stats.speed
        return playerScore > opponentScore ? player : opponent
    }
}
