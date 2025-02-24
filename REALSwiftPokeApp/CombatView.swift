import CoreData
import SwiftUI

struct CombatView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var selectedPokemon: Pokemon? = nil
    @State private var randomOpponent: Pokemon? = nil
    @State private var combatResult: String = ""
    @State private var showFavoritesOnly: Bool = false
    @State private var selectedPokemonOffset: CGFloat = -100
    @State private var selectedPokemonOpacity: Double = 0
    @State private var opponentOffset: CGFloat = 100
    @State private var opponentOpacity: Double = 0
    @State private var listScale: CGFloat = 0.9
    @State private var listOpacity: Double = 0
    @State private var resultScale: CGFloat = 0.8
    @State private var resultOpacity: Double = 0
    @State private var buttonOffset: CGFloat = 50
    @State private var buttonOpacity: Double = 0
    
    @State private var isAnimatingCombat: Bool = false
    @State private var pokemonScale: CGFloat = 1.0
    
    private func startAnimations() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            selectedPokemonOffset = 0
            selectedPokemonOpacity = 1
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            opponentOffset = 0
            opponentOpacity = 1
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            listScale = 1
            listOpacity = 1
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.4)) {
            buttonOffset = 0
            buttonOpacity = 1
        }
    }
    
    var body: some View {
        ZStack {
            // Arrière-plan avec gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.2), Color.purple.opacity(0.1)]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                if let selectedPokemon = selectedPokemon {
                    VStack(spacing: 15) {
                        Text("Votre Pokémon")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 20) {
                            AsyncImage(url: URL(string: selectedPokemon.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            .scaleEffect(isAnimatingCombat ? 1.2 : 1.0)
                            
                            VStack(alignment: .leading) {
                                Text(selectedPokemon.name.capitalized)
                                    .font(.title2)
                                    .bold()
                                
                                HStack {
                                    ForEach(selectedPokemon.types.split(separator: ","), id: \.self) { type in
                                        Text(String(type).capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(typeColor(for: String(type)))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .offset(x: selectedPokemonOffset)
                    .opacity(selectedPokemonOpacity)
                }
                
                if let opponent = randomOpponent {
                    VStack(spacing: 15) {
                        Text("Adversaire")
                            .font(.headline)
                            .foregroundColor(.gray)
                        
                        HStack(spacing: 20) {
                            AsyncImage(url: URL(string: opponent.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 80, height: 80)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.red, lineWidth: 2))
                            .scaleEffect(isAnimatingCombat ? 1.2 : 1.0)
                            
                            VStack(alignment: .leading) {
                                Text(opponent.name.capitalized)
                                    .font(.title2)
                                    .bold()
                                
                                HStack {
                                    ForEach(opponent.types.split(separator: ","), id: \.self) { type in
                                        Text(String(type).capitalized)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(typeColor(for: String(type)))
                                            .foregroundColor(.white)
                                            .cornerRadius(8)
                                    }
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .offset(x: opponentOffset)
                    .opacity(opponentOpacity)
                }
                
                VStack {
                    Toggle(isOn: $showFavoritesOnly) {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            Text("Pokémon favoris uniquement")
                        }
                    }
                    .padding()
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(10)
                    
                    List(filteredPokemons, id: \.id) { pokemon in
                        HStack {
                            AsyncImage(url: URL(string: pokemon.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                            
                            Text(pokemon.name.capitalized)
                                .font(.headline)
                            
                            Spacer()
                            
                        
                        }
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                selectedPokemon = pokemon
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
                .scaleEffect(listScale)
                .opacity(listOpacity)
                
                if !combatResult.isEmpty {
                    Text(combatResult)
                        .font(.title2)
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .scaleEffect(resultScale)
                        .opacity(resultOpacity)
                }
                
                if selectedPokemon != nil {
                    Button(action: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                            isAnimatingCombat = true
                            startCombat()
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                isAnimatingCombat = false
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Lancer le combat")
                                .font(.headline)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [.blue, .purple]),
                                                 startPoint: .leading,
                                                 endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(15)
                        .shadow(radius: 5)
                    }
                    .offset(y: buttonOffset)
                    .opacity(buttonOpacity)
                }
            }
            .padding()
        }
        .navigationTitle("Mode Combat")
        .onAppear {
            Task {
                await viewModel.fetchPokemonsWithDetails()
                startAnimations()
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
    
    private func startCombat() {
        guard let selectedPokemon = selectedPokemon else { return }
        randomOpponent = viewModel.pokemons.randomElement()
        
        if let opponent = randomOpponent {
            let winner = battleResult(player: selectedPokemon, opponent: opponent)
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                combatResult = "\(winner.name.capitalized) remporte le combat!"
                resultScale = 1
                resultOpacity = 1
            }
        }
    }
    
    private func battleResult(player: Pokemon, opponent: Pokemon) -> Pokemon {
        let playerScore = player.stats.hp + player.stats.attack + player.stats.defense + player.stats.speed
        let opponentScore = opponent.stats.hp + opponent.stats.attack + opponent.stats.defense + opponent.stats.speed
        return playerScore > opponentScore ? player : opponent
    }
}
