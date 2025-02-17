import CoreData
import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite: Bool = false
    @State private var scale: CGFloat = 1.0

    private func addFavorite() {
        let favoritePokemon = PokemonEntity(context: viewContext)
        favoritePokemon.name = pokemon.name
        favoritePokemon.image = pokemon.image
        favoritePokemon.types = pokemon.types // Types déjà en string
        favoritePokemon.stats = "HP: \(pokemon.stats.hp), Attaque: \(pokemon.stats.attack), Défense: \(pokemon.stats.defense), Vitesse: \(pokemon.stats.speed)"
        
        do {
            try viewContext.save()
            isFavorite = true
        } catch {
            print("Erreur lors de l'ajout aux favoris: \(error)")
        }
    }

    var body: some View {
        VStack {
                   Text(pokemon.name.capitalized)
                       .font(.largeTitle)
                       .padding()
                   
                   // Effet de zoom sur l'image
                   AsyncImage(url: URL(string: pokemon.image)) { image in
                       image.resizable()
                   } placeholder: {
                       ProgressView()
                   }
                   .frame(width: 150, height: 150)
                   .clipShape(Circle())
                   .padding()
                   .scaleEffect(scale) // Appliquer l'effet de zoom
                   .gesture(
                       TapGesture()
                           .onEnded {
                               withAnimation(.spring()) { // Animation de zoom
                                   scale = scale == 1.0 ? 1.9 : 1.0
                               }
                           }
                   )
            
            // Affichage des types et des statistiques avec animation
            VStack(alignment: .leading) {
                Text("Types: \(pokemon.types)") // Types sous forme de chaîne
                    .padding()
                
                VStack(alignment: .leading) {
                    // Assurer que stats sont des Int pour l'interpolation
                    Text("HP: \(pokemon.stats.hp)")
                    Text("Attaque: \(pokemon.stats.attack)")
                    Text("Défense: \(pokemon.stats.defense)")
                    Text("Vitesse: \(pokemon.stats.speed)")
                }
                .padding()
            }
            .transition(.opacity) // Animation des informations
            
            Button(action: addFavorite) {
                Text(isFavorite ? "Ajouté aux favoris" : "Ajouter aux favoris")
                    .padding()
                    .background(isFavorite ? Color.green : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .animation(.easeInOut, value: isFavorite)
            }
            .padding()
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(false) // Assure-toi que le bouton retour est visible
        .navigationTitle(pokemon.name.capitalized) // Titre du détail Pokémon
        .animation(.default) // Animation de base pour la vue
    }
}
