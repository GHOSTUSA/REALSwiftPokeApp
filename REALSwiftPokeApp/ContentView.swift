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
    
    private let pokemonTypes = [
        "fire", "water", "grass", "electric", "ground", "rock",
        "flying", "psychic", "fighting", "poison", "bug", "ice",
        "dragon", "ghost", "steel", "fairy", "normal"
    ]
    
    var filteredAndSortedPokemons: [Pokemon] {
        var filteredPokemons = viewModel.pokemons
        
        if !searchText.isEmpty {
            filteredPokemons = filteredPokemons.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        
        if let selectedType = selectedType {
            filteredPokemons = filteredPokemons.filter { pokemon in
                let types = pokemon.types
                    .split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces).lowercased() }
                return types.contains(selectedType.lowercased())
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
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            searchBarOffset = 0
            searchBarOpacity = 1
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            filtersScale = 1
            filtersOpacity = 1
        }
        
        withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
            listOpacity = 1
        }
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.6)) {
            combatButtonOffset = 0
            combatButtonOpacity = 1
        }
    }
    
    private func typeColor(for type: String) -> Color {
        switch type.trimmingCharacters(in: .whitespaces).lowercased() {
        case "fire": return .red
        case "water": return .blue
        case "grass": return .green
        case "electric": return .yellow
        case "ground": return .brown
        case "rock": return .gray
        case "flying": return .cyan
        case "psychic": return .purple
        case "fighting": return .orange
        case "poison": return .purple
        case "bug": return .green
        case "ice": return .blue
        case "dragon": return .purple
        case "ghost": return .purple
        case "steel": return .gray
        case "fairy": return .pink
        default: return .gray
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [
                    isDarkMode ? Color.black : Color.blue.opacity(0.1),
                    isDarkMode ? Color.gray.opacity(0.3) : Color.white
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 16) {
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

                    VStack(spacing: 12) {
                        Picker("Filtrer par type", selection: $selectedType) {
                            Text("Tous").tag(nil as String?)
                            ForEach(pokemonTypes, id: \.self) { type in
                                Text(type.capitalized).tag(type as String?)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        .padding(.horizontal)
                        .onChange(of: selectedType) { _ in
                            withAnimation {
                            }
                        }
                        
                        Picker("Trier par", selection: $sortOption) {
                            Text("A-Z").tag(SortOption.alphabetical)
                            Text("ATK").tag(SortOption.attack)
                            Text("DEF").tag(SortOption.defense)
                            Text("VIT").tag(SortOption.speed)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        Toggle("Favoris uniquement", isOn: $showOnlyFavorites)
                            .padding(.horizontal)
                    }
                    .scaleEffect(filtersScale)
                    .opacity(filtersOpacity)

                    List(filteredAndSortedPokemons, id: \.id) { pokemon in
                        HStack(spacing: 15) {
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
