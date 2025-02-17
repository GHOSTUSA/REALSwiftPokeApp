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
    @Published var selectedPokemon: Pokemon? = nil
    let context = PersistenceController.shared.container.viewContext
    
    // Récupérer la liste des Pokémon + leurs détails en parallèle
    func fetchPokemonsWithDetails() async {
        // Vérifier si les Pokémon sont déjà dans Core Data
        if loadFromCoreData() {
            return // Si déjà chargés, ne pas faire de nouvelle requête API
        }

        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else {
            print("URL invalide")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)

            // Récupérer les détails en parallèle
            let detailedPokemons: [Pokemon] = await withTaskGroup(of: Pokemon?.self) { group in
                for entry in decodedResponse.results {
                    group.addTask {
                        if let details = await self.fetchPokemonDetails(for: entry) {
                            return details // Retourner directement le Pokémon détaillé
                        }
                        return nil
                    }
                }

                var results: [Pokemon] = []
                for await pokemon in group {
                    if let pokemon = pokemon {
                        results.append(pokemon)
                    }
                }
                return results
            }

            // Mise à jour de l'UI sur le thread principal
            DispatchQueue.main.async {
                self.pokemons = detailedPokemons
                self.saveToCoreData() // Sauvegarder dans Core Data après récupération
            }

        } catch {
            print("Erreur lors de la récupération des Pokémon : \(error)")
        }
    }

    // Récupérer les détails d'un Pokémon
    func fetchPokemonDetails(for entry: PokemonEntry) async -> Pokemon? {
        guard let url = URL(string: entry.url) else {
            print("URL invalide")
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedPokemon = try JSONDecoder().decode(PokemonDetail.self, from: data)

            return Pokemon(
                id: entry.id,
                name: entry.name.capitalized,
                image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(entry.id).png",
                types: decodedPokemon.types.map { $0.type.name }.joined(separator: ", "),
                stats: Stats(
                    hp: decodedPokemon.stats.first(where: { $0.stat.name == "hp" })?.baseStat ?? 0,
                    attack: decodedPokemon.stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 0,
                    defense: decodedPokemon.stats.first(where: { $0.stat.name == "defense" })?.baseStat ?? 0,
                    speed: decodedPokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
                ),
                isFavorite: false
            )

        } catch {
            print("Erreur lors de la récupération des détails du Pokémon : \(error)")
            return nil
        }
    }

    // Sauvegarde dans Core Data
    private func saveToCoreData() {
        for pokemon in pokemons {
            // Vérifier si ce Pokémon existe déjà dans Core Data
            let fetchRequest: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %d", pokemon.id)
            do {
                let existingPokemons = try context.fetch(fetchRequest)
                if existingPokemons.isEmpty {
                    // Si le Pokémon n'existe pas, on le crée
                    let entity = PokemonEntity(context: context)
                    entity.id = Int64(pokemon.id)
                    entity.name = pokemon.name
                    entity.image = pokemon.image
                    entity.types = pokemon.types
                    entity.isFavorite = pokemon.isFavorite
                    entity.hp = Int64(pokemon.stats.hp)
                    entity.attack = Int64(pokemon.stats.attack)
                    entity.defense = Int64(pokemon.stats.defense)
                    entity.speed = Int64(pokemon.stats.speed)
                }
            } catch {
                print("Erreur lors de la vérification ou sauvegarde du Pokémon dans CoreData: \(error)")
            }
        }
        do {
            try context.save()
        } catch {
            print("Erreur lors de la sauvegarde dans CoreData: \(error)")
        }
    }

    // Charger depuis Core Data
    private func loadFromCoreData() -> Bool {
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        do {
            let results = try context.fetch(request)
            if !results.isEmpty {
                self.pokemons = results.map { entity in
                    return Pokemon(
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
                return true
            }
        } catch {
            print("Erreur lors du chargement depuis CoreData: \(error)")
        }
        return false
    }
}

