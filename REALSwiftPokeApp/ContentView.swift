import SwiftUI
import CoreData

struct ContentView: View {
    @StateObject private var viewModel = PokemonViewModel()
    @State private var searchText = ""
    @State private var selectedType: String? = nil
    @State private var sortOption: SortOption = .alphabetical
    @State private var isSheetPresented = false
    @State private var selectedPokemon: Pokemon? = nil
    @State private var showOnlyFavorites: Bool = false
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    // États pour les animations
    @State private var searchBarOffset: CGFloat = -50
    @State private var searchBarOpacity: Double = 0
    @State private var filtersScale: CGFloat = 0.8
    @State private var filtersOpacity: Double = 0
    @State private var listOpacity: Double = 0
    @State private var combatButtonOffset: CGFloat = 100
    @State private var combatButtonOpacity: Double = 0
    
    enum SortOption {
        case alphabetical, attack, defense, speed
    }
    
    var filteredAndSortedPokemons: [Pokemon] {
        var filteredPokemons = viewModel.pokemons
        
        if !searchText.isEmpty {
            filteredPokemons = filteredPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        if let selectedType = selectedType {
            filteredPokemons = filteredPokemons.filter { pokemon in
                pokemon.types.contains(selectedType)
            }
        }
        
        if showOnlyFavorites {
            filteredPokemons = filteredPokemons.filter { $0.isFavorite }
        }
        
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
    
    private func startAnimations() {
        // Animation de la barre de recherche
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            searchBarOffset = 0
            searchBarOpacity = 1
        }
        
        // Animation des filtres
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            filtersScale = 1
            filtersOpacity = 1
        }
        
        // Animation de la liste
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            listOpacity = 1
        }
        
        // Animation du bouton combat
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
            combatButtonOffset = 0
            combatButtonOpacity = 1
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Gradient de fond
                LinearGradient(gradient: Gradient(colors: [
                    isDarkMode ? Color.black : Color.blue.opacity(0.1),
                    isDarkMode ? Color.gray.opacity(0.3) : Color.white
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
                    // Barre de recherche stylisée
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Rechercher par nom", text: $searchText)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(12)
                    .shadow(radius: 3)
                    .padding(.horizontal)
                    .offset(y: searchBarOffset)
                    .opacity(searchBarOpacity)
                    
                    // Section des filtres
                    VStack(spacing: 12) {
                        // Filtre par type
                        Picker("Filtrer par type", selection: $selectedType) {
                            Text("Tous").tag(nil as String?)
                            Text("Feu").tag("fire")
                            Text("Eau").tag("water")
                            Text("Plante").tag("grass")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        // Options de tri
                        Picker("Trier par", selection: $sortOption) {
                            Text("A-Z").tag(SortOption.alphabetical)
                            Text("ATK").tag(SortOption.attack)
                            Text("DEF").tag(SortOption.defense)
                            Text("VIT").tag(SortOption.speed)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        // Toggle favoris
                        Toggle("Favoris uniquement", isOn: $showOnlyFavorites)
                            .padding(.horizontal)
                    }
                    .scaleEffect(filtersScale)
                    .opacity(filtersOpacity)
                    
                    // Liste des Pokémon
                    List(filteredAndSortedPokemons, id: \.id) { pokemon in
                        HStack(spacing: 15) {
                            // Image du Pokémon
                            AsyncImage(url: URL(string: pokemon.image)) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .shadow(radius: 2)
                            .padding(.vertical, 5)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(pokemon.name.capitalized)
                                    .font(.headline)
                                
                                // Types
                                HStack {
                                    ForEach(pokemon.types.split(separator: ","), id: \.self) { type in
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
                            
                            Spacer()
                            
                            // Bouton favori
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    toggleFavorite(pokemon: pokemon)
                                }
                            }) {
                                Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                                    .font(.title2)
                                    .foregroundColor(pokemon.isFavorite ? .red : .gray)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedPokemon = pokemon
                            isSheetPresented.toggle()
                        }
                    }
                    .listStyle(PlainListStyle())
                    .opacity(listOpacity)
                    
                    // Bouton mode combat
                    NavigationLink(destination: CombatView()) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            Text("Mode Combat")
                                .fontWeight(.bold)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        .padding(.horizontal)
                    }
                    .offset(y: combatButtonOffset)
                    .opacity(combatButtonOpacity)
                }
                .padding(.vertical)
            }
            .navigationTitle("Pokédex")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        withAnimation {
                            isDarkMode.toggle()
                        }
                    }) {
                        Image(systemName: isDarkMode ? "sun.max.fill" : "moon.fill")
                            .font(.title3)
                            .foregroundColor(isDarkMode ? .yellow : .primary)
                    }
                }
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .onAppear {
                Task {
                    await viewModel.fetchPokemonsWithDetails()
                    startAnimations()
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
