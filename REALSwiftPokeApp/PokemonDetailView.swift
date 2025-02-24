import SwiftUI
import CoreData

struct PokemonDetailView: View {
    @Binding var pokemon: Pokemon?
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var viewModel: PokemonViewModel  // Ajout du ViewModel
    @State private var scale: CGFloat = 1.0
    @State private var opacity: Double = 0  // Pour l'animation de fade
    @State private var offset: CGFloat = 50 // Pour l'animation de slide
    
    // Initialisation avec le ViewModel
    init(pokemon: Binding<Pokemon?>, viewModel: PokemonViewModel) {
        self._pokemon = pokemon
        self.viewModel = viewModel
    }
    
    private func toggleFavorite() {
        guard let pokemon = pokemon else { return }
        viewModel.toggleFavorite(pokemon: pokemon)  // Utiliser le ViewModel
    }
    
    var body: some View {
        if let pokemon = pokemon {
            ZStack {
                LinearGradient(gradient: Gradient(colors: backgroundColors(for: pokemon.types)),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text(pokemon.name.capitalized)
                            .font(.largeTitle)
                            .bold()
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                            .opacity(opacity)  // Animation de fade
                            .offset(y: offset) // Animation de slide
                        
                        AsyncImage(url: URL(string: pokemon.image)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.3)))
                        .scaleEffect(scale)
                        .shadow(radius: 10)
                        .opacity(opacity)  // Animation de fade
                        .offset(y: offset) // Animation de slide
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                        scale = scale == 1.0 ? 1.3 : 1.0
                                    }
                                }
                        )
                        
                        HStack {
                            ForEach(pokemon.types.split(separator: ","), id: \.self) { type in
                                Text(type.capitalized)
                                    .font(.headline)
                                    .padding(10)
                                    .background(typeColor(for: String(type)))
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                            }
                        }
                        .opacity(opacity)  // Animation de fade
                        .offset(y: offset) // Animation de slide
                        
                        VStack(alignment: .leading, spacing: 10) {
                            StatBar(label: "HP", value: pokemon.stats.hp, color: .green)
                            StatBar(label: "Attaque", value: pokemon.stats.attack, color: .red)
                            StatBar(label: "Défense", value: pokemon.stats.defense, color: .blue)
                            StatBar(label: "Vitesse", value: pokemon.stats.speed, color: .orange)
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(15)
                        .padding(.horizontal)
                        .opacity(opacity)  // Animation de fade
                        .offset(y: offset) // Animation de slide
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                toggleFavorite()
                            }
                        }) {
                            HStack {
                                Image(systemName: pokemon.isFavorite ? "heart.fill" : "heart")
                                    .foregroundColor(.white)
                                    .font(.title2)
                                Text(pokemon.isFavorite ? "Ajouté aux favoris" : "Ajouter aux favoris")
                                    .bold()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(pokemon.isFavorite ? Color.green : Color.pink)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)
                        .opacity(opacity)  // Animation de fade
                        .offset(y: offset) // Animation de slide
                    }
                    .padding()
                }
            }
            .navigationTitle(pokemon.name.capitalized)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Animation d'entrée
                withAnimation(.easeOut(duration: 0.8)) {
                    opacity = 1
                    offset = 0
                }
            }
        } else {
            EmptyView()
        }
    }
}

// Les autres structures restent identiques...

// Composant pour afficher les barres de stats
struct StatBar: View {
    var label: String
    var value: Int64
    var color: Color

    var body: some View {
        VStack(alignment: .leading) {
            Text("\(label): \(value)")
                .font(.headline)
                .foregroundColor(.white)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: geometry.size.width, height: 10)
                        .foregroundColor(Color.white.opacity(0.3))
                    
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: min(CGFloat(value) / 100.0 * geometry.size.width, geometry.size.width),
                               height: 10)
                        .foregroundColor(color)
                        .animation(.easeInOut(duration: 0.8), value: value)
                }
            }
            .frame(height: 10)
        }
    }
}

// Fonction pour récupérer la couleur du type de Pokémon
func typeColor(for type: String) -> Color {
    switch type.lowercased() {
    case "fire": return Color.red
    case "water": return Color.blue
    case "grass": return Color.green
    case "electric": return Color.yellow
    case "ice": return Color.cyan
    case "fighting": return Color.orange
    case "poison": return Color.purple
    case "ground": return Color.brown
    case "flying": return Color.indigo
    case "psychic": return Color.pink
    case "bug": return Color.green.opacity(0.7)
    case "rock": return Color.gray
    case "ghost": return Color.purple.opacity(0.7)
    case "dragon": return Color.purple
    case "dark": return Color.black
    case "steel": return Color.gray.opacity(0.7)
    case "fairy": return Color.pink.opacity(0.7)
    default: return Color.gray
    }
}

// Fonction pour obtenir une couleur de fond en fonction du type
func backgroundColors(for types: String) -> [Color] {
    let typeList = types.split(separator: ",").map { String($0) }
    let colors = typeList.map { typeColor(for: $0) }
    return colors.isEmpty ? [Color.gray, Color.black] : colors
}
