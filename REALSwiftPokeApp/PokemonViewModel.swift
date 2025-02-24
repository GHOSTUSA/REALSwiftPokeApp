import CoreData
import Foundation

// Modèle pour la réponse de la liste des Pokémon
struct PokemonListResponse: Codable {
    let results: [PokemonEntry]
}

// Modèle détaillé pour un Pokémon
struct PokemonDetail: Codable {
    let types: [PokemonType]
    let stats: [PokemonStat]
}

struct PokemonType: Codable {
    let type: PokemonTypeName
}

struct PokemonTypeName: Codable {
    let name: String
}

struct PokemonStat: Codable {
    let baseStat: Int64
    let stat: PokemonStatName
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"
        case stat
    }
}

struct PokemonStatName: Codable {
    let name: String
}

class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    let context = PersistenceController.shared.container.viewContext
    
    func fetchPokemonsWithDetails() async {
        //clearCoreData() // Vider CoreData au démarrage
            
            if loadFromCoreData() {
                print("Données chargées depuis CoreData")
                return
            }

        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            print("URL invalide")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            print("Nombre de Pokémon dans la réponse API: \(decodedResponse.results.count)")

            // Utiliser un set pour éviter les doublons
            var uniquePokemons: [Pokemon] = []
            var seenPokemonIDs = Set<Int>()

            await withTaskGroup(of: Pokemon?.self) { group in
                for entry in decodedResponse.results {
                    group.addTask {
                        await self.fetchPokemonDetails(for: entry)
                    }
                }

                for await pokemon in group {
                    if let pokemon = pokemon, !seenPokemonIDs.contains(pokemon.id) {
                        seenPokemonIDs.insert(pokemon.id) // Marque cet ID comme ajouté
                        uniquePokemons.append(pokemon)
                    }
                }
            }

            // Trier par ID pour assurer l'ordre correct
            uniquePokemons.sort { $0.id < $1.id }

            print("Nombre de Pokémon uniques récupérés: \(uniquePokemons.count)")

            DispatchQueue.main.async {
                self.pokemons = uniquePokemons
            }

            // Sauvegarde après la mise à jour
            saveToCoreData()
	

        } catch {
            print("Erreur lors de la récupération des Pokémon: \(error)")
        }
    }


    private func fetchPokemonDetails(for entry: PokemonEntry) async -> Pokemon? {
        guard let url = URL(string: entry.url) else {
            print("URL invalide pour \(entry.name)")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)

            let pokemon = entry.toPokemon(with: pokemonDetail)

            if pokemon.id == 0 {
                print("⚠️ Attention : Pokémon avec ID 0 détecté → \(pokemon.name)")
            }

            return pokemon

        } catch {
            print("Erreur pour \(entry.name): \(error)")
            return nil
        }
    }


    private func saveToCoreData() {
        // Supprimer les anciennes données avant de sauvegarder
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PokemonEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            
            // Sauvegarder les nouvelles données
            for pokemon in pokemons {
                let entity = PokemonEntity(context: context)
                entity.id = Int64(pokemon.id)
                entity.name = pokemon.name
                entity.image = pokemon.image
                entity.types = pokemon.types
                entity.hp = Int64(pokemon.stats.hp)
                entity.attack = Int64(pokemon.stats.attack)
                entity.defense = Int64(pokemon.stats.defense)
                entity.speed = Int64(pokemon.stats.speed)
                entity.isFavorite = pokemon.isFavorite
            }
            
            try context.save()
            print("Données sauvegardées dans CoreData avec succès")
        } catch {
            print("Erreur lors de la sauvegarde dans CoreData: \(error)")
        }
    }

    private func loadFromCoreData() -> Bool {
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                self.pokemons = results.map { entity in
                    Pokemon(
                        id: Int(entity.id),
                        name: entity.name ?? "Inconnu",
                        image: entity.image ?? "",
                        types: entity.types ?? "",
                        stats: Stats(
                            hp: Int64(entity.hp),
                            attack: Int64(entity.attack),
                            defense: Int64(entity.defense),
                            speed: Int64(entity.speed)
                        ),
                        isFavorite: entity.isFavorite
                    )
                }
                print("Nombre de Pokémon chargés depuis CoreData: \(self.pokemons.count)")
                return true
            }
        } catch {
            print("Erreur lors du chargement depuis CoreData: \(error)")
        }
        return false
    }
    
    func toggleFavorite(pokemon: Pokemon) {
        if let index = pokemons.firstIndex(where: { $0.id == pokemon.id }) {
            pokemons[index].isFavorite.toggle()

            // Mise à jour dans Core Data
            let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
            request.predicate = NSPredicate(format: "id == %d", pokemon.id)
            
            do {
                let results = try context.fetch(request)
                if let entity = results.first {
                    entity.isFavorite = pokemons[index].isFavorite
                    try context.save()
                }
            } catch {
                print("Erreur lors de la mise à jour du favori dans Core Data: \(error)")
            }
        }
    }

    
    private func clearCoreData() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = PokemonEntity.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("CoreData vidé avec succès")
        } catch {
            print("Erreur lors de la suppression des données CoreData: \(error)")
        }
    }

}
