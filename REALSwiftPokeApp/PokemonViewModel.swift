import CoreData
import Foundation

// Modèles inchangés...
struct PokemonListResponse: Codable {
    let results: [PokemonEntry]
}

struct PokemonDetail: Codable {
    let types: [PokemonType]
    let stats: [PokemonStat]
    let id: Int // Ajout de l'ID dans le modèle
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

@MainActor // Assure que toutes les mises à jour de @Published sont sur le thread principal
class PokemonViewModel: ObservableObject {
    @Published var pokemons: [Pokemon] = []
    let context = PersistenceController.shared.container.viewContext
    
    func fetchPokemonsWithDetails() async {
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
            
            var uniquePokemons: [Pokemon] = []
            var seenPokemonIDs = Set<Int>()

            await withTaskGroup(of: Pokemon?.self) { group in
                for entry in decodedResponse.results {
                    group.addTask {
                        await self.fetchPokemonDetails(for: entry)
                    }
                }

                for await pokemon in group {
                    if let pokemon = pokemon,
                       pokemon.id > 0, // Vérifie que l'ID est valide
                       !seenPokemonIDs.contains(pokemon.id) {
                        seenPokemonIDs.insert(pokemon.id)
                        uniquePokemons.append(pokemon)
                    }
                }
            }

            // Trier et filtrer les Pokémon
            uniquePokemons = uniquePokemons
                .filter { $0.id > 0 && $0.id <= 151 } // Assure qu'on a que les 151 premiers
                .sorted { $0.id < $1.id }

            // Mise à jour sur le thread principal
            self.pokemons = uniquePokemons
            
            // Sauvegarde dans CoreData
            await saveToCoreData(pokemons: uniquePokemons)

        } catch {
            print("Erreur lors de la récupération des Pokémon: \(error)")
        }
    }

    private func fetchPokemonDetails(for entry: PokemonEntry) async -> Pokemon? {
        guard let url = URL(string: entry.url) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let pokemonDetail = try JSONDecoder().decode(PokemonDetail.self, from: data)
            
            // Vérification de l'ID
            guard pokemonDetail.id > 0 && pokemonDetail.id <= 151 else { return nil }

            let pokemon = Pokemon(
                id: pokemonDetail.id, // Utilise l'ID de l'API
                name: entry.name,
                image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemonDetail.id).png",
                types: pokemonDetail.types.map { $0.type.name }.joined(separator: ","),
                stats: Stats(
                    hp: pokemonDetail.stats[0].baseStat,
                    attack: pokemonDetail.stats[1].baseStat,
                    defense: pokemonDetail.stats[2].baseStat,
                    speed: pokemonDetail.stats[5].baseStat
                ),
                isFavorite: false
            )

            return pokemon
        } catch {
            print("Erreur pour \(entry.name): \(error)")
            return nil
        }
    }

    private func saveToCoreData(pokemons: [Pokemon]) async {
        await MainActor.run {
            // Nettoyer les données existantes
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
    }

    private func loadFromCoreData() -> Bool {
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        
        do {
            let results = try context.fetch(request)
            guard !results.isEmpty else { return false }
            
            let loadedPokemons = results
                .filter { $0.id > 0 && $0.id <= 151 } // Filtre les IDs invalides
                .map { entity in
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
            
            self.pokemons = loadedPokemons
            print("Nombre de Pokémon chargés depuis CoreData: \(loadedPokemons.count)")
            return true
        } catch {
            print("Erreur lors du chargement depuis CoreData: \(error)")
            return false
        }
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
}
