//
//  PokemonViewModel.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import CoreData
import Foundation

struct PokemonListResponse: Codable {
    let results: [PokemonEntry]
}

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
    let baseStat: Int
    let stat: PokemonStatName
    
    enum CodingKeys: String, CodingKey {
        case baseStat = "base_stat"  // Le nom correct du champ dans l'API est "base_stat"
        case stat
    }
}


struct PokemonStatName: Codable {
    let name: String
}




class PokemonViewModel: ObservableObject {
    @Published var pokemons: [PokemonEntry] = []
    @Published var selectedPokemon: Pokemon? = nil  // Pokémon détaillé sélectionné
    let context = PersistenceController.shared.container.viewContext
    
    // Récupérer les Pokémon
    func fetchPokemons() async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=100") else {
            print("URL invalide")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            
            // Mise à jour sur le fil principal
            DispatchQueue.main.async {
                self.pokemons = decodedResponse.results
            }
        } catch {
            print("Erreur lors de la récupération des Pokémon : \(error)")
        }
    }

    // Récupérer les détails d'un Pokémon à partir de l'URL
    func fetchPokemonDetails(for pokemon: PokemonEntry) async {
        let pokemonDetailsURL = pokemon.url
        guard let url = URL(string: pokemonDetailsURL) else {
            print("URL invalide")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedPokemon = try JSONDecoder().decode(PokemonDetail.self, from: data)

            // Mettre à jour l'objet sélectionné avec ses détails
            DispatchQueue.main.async {
                self.selectedPokemon = Pokemon(
                    id: pokemon.id,
                    name: pokemon.name.capitalized,
                    image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png",
                    types: decodedPokemon.types.map { $0.type.name },  // Types des Pokémon
                    stats: Stats(
                        hp: decodedPokemon.stats.first(where: { $0.stat.name == "hp" })?.baseStat ?? 0,
                        attack: decodedPokemon.stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 0,
                        defense: decodedPokemon.stats.first(where: { $0.stat.name == "defense" })?.baseStat ?? 0,
                        speed: decodedPokemon.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
                    )
                )
            }
        } catch {
            print("Erreur lors de la récupération des détails du Pokémon : \(error)")
        }
    }




    
    private func saveToCoreData() {
        for pokemon in pokemons {
            let entity = PokemonEntity(context: context)
            entity.name = pokemon.name
            entity.image = "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(pokemon.id).png"
        }
        try? context.save()
    }
    
    private func loadFromCoreData() -> Bool {
        let request: NSFetchRequest<PokemonEntity> = PokemonEntity.fetchRequest()
        if let results = try? context.fetch(request), !results.isEmpty {
            self.pokemons = results.map { PokemonEntry(name: $0.name ?? "Inconnu", url: $0.image ?? "") }
            return true
        }
        return false
    }
}
