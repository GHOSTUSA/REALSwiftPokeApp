import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var searchText = "" // Pour la recherche par nom
    @State private var selectedType: String? = nil // Pour le filtre par type
    @State private var sortOption: SortOption = .alphabetical // Pour le tri
    @State private var isSheetPresented = false
    @State private var selectedPokemon: Pokemon? = nil // Pokémon sélectionné pour afficher la Sheet
    
    // Enums pour le tri
    enum SortOption {
        case alphabetical
        case attack
        case defense
        case speed
    }
    
    var filteredAndSortedPokemons: [Pokemon] {
        var filteredPokemons = viewModel.pokemons
        
        // Filtrer par nom
        if !searchText.isEmpty {
            filteredPokemons = filteredPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        // Filtrer par type
        if let selectedType = selectedType {
            filteredPokemons = filteredPokemons.filter { pokemon in
                pokemon.types.contains(selectedType)
            }
        }
        
        // Trier
        switch sortOption {
        case .alphabetical:
            filteredPokemons.sort { $0.name.lowercased() < $1.name.lowercased() }
        case .attack:
            filteredPokemons.sort { $0.stats.attack > $1.stats.attack }
        case .defense:
            filteredPokemons.sort { $0.stats.defense > $1.stats.defense }
        case .speed:
            filteredPokemons.sort { $0.stats.speed > $1.stats.speed }
        }
        
        return filteredPokemons
    }

    var body: some View {
        NavigationView {
            VStack {
                // Barre de recherche
                TextField("Rechercher par nom", text: $searchText)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                // Filtre par type
                Picker("Filtrer par type", selection: $selectedType) {
                    Text("Tous").tag(nil as String?)
                    Text("Feu").tag("fire")
                    Text("Eau").tag("water")
                    Text("Plante").tag("grass")
                    // Ajouter d'autres types si nécessaire
                }
                .pickerStyle(MenuPickerStyle())
                .padding()
                
                // Options de tri
                Picker("Trier par", selection: $sortOption) {
                    Text("Alphabétique").tag(SortOption.alphabetical)
                    Text("Attaque").tag(SortOption.attack)
                    Text("Défense").tag(SortOption.defense)
                    Text("Vitesse").tag(SortOption.speed)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Liste des Pokémon filtrés et triés
                List(filteredAndSortedPokemons, id: \.id) { pokemon in
                    HStack {
                        AsyncImage(url: URL(string: pokemon.image)) { image in
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
                        isSheetPresented.toggle() // Afficher la Sheet
                    }
                    .transition(.scale) // Animation lors du changement dans la liste
                }
                
                NavigationLink(destination: CombatView()) {
                                    Text("Mode Combat")
                                        .padding()
                                        .background(Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                                .padding()
                .navigationTitle("Pokémon")
                .onAppear {
                    Task {
                        await viewModel.fetchPokemonsWithDetails()
                    }
                }

                .sheet(isPresented: $isSheetPresented) {
                    if let selectedPokemon = selectedPokemon {
                        PokemonDetailView(pokemon: selectedPokemon) // Passer le Pokémon sélectionné à la Sheet
                    }
                }
            }
        }
        .animation(.easeInOut, value: filteredAndSortedPokemons) // Animation lors de l'ajout/suppression des Pokémon
    }
}
