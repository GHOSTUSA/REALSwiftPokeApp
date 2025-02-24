import SwiftUI
import CoreData

struct PokemonDetailView: View {
    @Binding var pokemon: Pokemon?
    @Environment(\.managedObjectContext) private var viewContext
    @ObservedObject private var viewModel: PokemonViewModel
    @State private var scale: CGFloat = 1.0
    
    // États pour les animations
    @State private var titleOpacity: Double = 0
    @State private var imageScale: CGFloat = 0.5
    @State private var imageOpacity: Double = 0
    @State private var typesOffset: CGFloat = 100
    @State private var typesOpacity: Double = 0
    @State private var statsOffset: CGFloat = 100
    @State private var statsOpacity: Double = 0
    @State private var buttonScale: CGFloat = 0.8
    @State private var buttonOpacity: Double = 0
    
    init(pokemon: Binding<Pokemon?>, viewModel: PokemonViewModel) {
        self._pokemon = pokemon
        self.viewModel = viewModel
    }
    
    private func toggleFavorite() {
        guard let pokemon = pokemon else { return }
        viewModel.toggleFavorite(pokemon: pokemon)
    }
    
    private func startAnimations() {
        // Animation du titre
        withAnimation(.easeOut(duration: 0.6)) {
            titleOpacity = 1
        }
        
        // Animation de l'image
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.3)) {
            imageScale = 1.0
            imageOpacity = 1
        }
        
        // Animation des types
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
            typesOffset = 0
            typesOpacity = 1
        }
        
        // Animation des stats
        withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.7)) {
            statsOffset = 0
            statsOpacity = 1
        }
        
        // Animation du bouton
        withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.9)) {
            buttonScale = 1
            buttonOpacity = 1
        }
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
                            .opacity(titleOpacity)
                        
                        AsyncImage(url: URL(string: pokemon.image)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .padding()
                        .background(Circle().fill(Color.white.opacity(0.3)))
                        .scaleEffect(imageScale)
                        .opacity(imageOpacity)
                        .shadow(radius: 10)
                        .gesture(
                            TapGesture()
                                .onEnded {
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                        scale = scale == 1.0 ? 1.9 : 1.0
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
                        .offset(y: typesOffset)
                        .opacity(typesOpacity)
                        
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
                        .offset(y: statsOffset)
                        .opacity(statsOpacity)
                        
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
                        .scaleEffect(buttonScale)
                        .opacity(buttonOpacity)
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationTitle(pokemon.name.capitalized)
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                startAnimations()
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
