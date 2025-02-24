import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var searchText = "" // Pour la recherche par nom
    @State private var selectedType: String? = nil // Pour le filtre par type
    @State private var sortOption: SortOption = .alphabetical // Pour le tri
    @State private var isSheetPresented = false
    @State private var selectedPokemon: Pokemon? = nil // Pokémon sélectionné pour afficher la Sheet
    @State private var showOnlyFavorites: Bool = false // Afficher uniquement les favoris
    @AppStorage("isDarkMode") private var isDarkMode = false

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
        
        // Filtrer les favoris si nécessaire
        if showOnlyFavorites {
            filteredPokemons = filteredPokemons.filter { $0.isFavorite }
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
                }
                .pickerStyle(MenuPickerStyle())
                
                // Options de tri
                Picker("Trier par", selection: $sortOption) {
                    Text("Alphabétique").tag(SortOption.alphabetical)
                    Text("Attaque").tag(SortOption.attack)
                    Text("Défense").tag(SortOption.defense)
                    Text("Vitesse").tag(SortOption.speed)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Option pour afficher uniquement les favoris
                Toggle("Afficher les favoris seulement", isOn: $showOnlyFavorites)
                    .padding()
                
                // Liste des Pokémon
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
                        
                        Spacer()
                        
                        // Bouton de favori avec le cœur
                        Button(action: {
                            toggleFavorite(pokemon: pokemon)  // Appel de toggleFavorite ici
                        }) {
                            Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                                .foregroundColor(pokemon.isFavorite ? .red : .gray)
                        }
                        .buttonStyle(PlainButtonStyle())  // Utiliser PlainButtonStyle pour éviter les effets visuels par défaut du bouton
                    }
                    .onTapGesture {
                        selectedPokemon = pokemon
                        isSheetPresented.toggle()
                    }
                }

                
                // Bouton mode combat
                NavigationLink(destination: CombatView()) {
                    Text("Mode Combat")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .navigationTitle("Pokémon")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isDarkMode.toggle()
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .foregroundColor(.primary)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                Task {
                    await viewModel.fetchPokemonsWithDetails()
                }
            }
            .sheet(isPresented: $isSheetPresented) {
                if let pokemon = selectedPokemon {
                    PokemonDetailView(pokemon: .constant(selectedPokemon), viewModel: viewModel)
                }
            }
        }
    }
    
    private func toggleFavorite(pokemon: Pokemon) {
        viewModel.toggleFavorite(pokemon: pokemon)
    }
}
