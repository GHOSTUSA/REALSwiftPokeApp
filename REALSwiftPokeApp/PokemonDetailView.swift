import CoreData
import SwiftUI

struct PokemonDetailView: View {
    var pokemon: PokemonEntry
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite: Bool = false

    private func addFavorite() {
        let favoritePokemon = PokemonEntity(context: viewContext)
        favoritePokemon.name = pokemon.name
        favoritePokemon.image = pokemon.url
        favoritePokemon.types = "Type(s) ici"
        favoritePokemon.stats = "Stats ici"
        
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
            
            // Affichage de l'image du Pokémon avec animation
            AsyncImage(url: URL(string: pokemon.toPokemon().image)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .padding()
            .transition(.scale) // Animation d'apparition de l'image
            
            // Affichage des types et des statistiques avec animation
            VStack(alignment: .leading) {
                Text("Types: Feu, Eau") // Remplacer avec les types réels
                    .padding()
                VStack(alignment: .leading) {
                    Text("HP: 35")
                    Text("Attaque: 55")
                    Text("Défense: 40")
                    Text("Vitesse: 90")
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

