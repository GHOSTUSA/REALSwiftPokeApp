import CoreData
import SwiftUI

struct PokemonDetailView: View {
    var pokemon: Pokemon
    @Environment(\.managedObjectContext) private var viewContext
    @State private var isFavorite: Bool = false

    private func addFavorite() {
        let favoritePokemon = PokemonEntity(context: viewContext)
        favoritePokemon.name = pokemon.name
        favoritePokemon.image = pokemon.image
        favoritePokemon.types = pokemon.types.joined(separator: ", ") // Convertir les types en une chaîne
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
            
            // Affichage de l'image du Pokémon
            AsyncImage(url: URL(string: pokemon.image)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .frame(width: 150, height: 150)
            .clipShape(Circle())
            .padding()
            
            // Affichage des types du Pokémon
            Text("Types: \(pokemon.types.joined(separator: ", "))")
                .padding()
            
            // Affichage des statistiques
            VStack(alignment: .leading) {
                Text("HP: \(pokemon.stats.hp)")
                Text("Attaque: \(pokemon.stats.attack)")
                Text("Défense: \(pokemon.stats.defense)")
                Text("Vitesse: \(pokemon.stats.speed)")
            }
            .padding()
            
            // Bouton pour ajouter aux favoris
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
    }
}
