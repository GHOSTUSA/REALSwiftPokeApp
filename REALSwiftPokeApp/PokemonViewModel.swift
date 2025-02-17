//
//  PokemonViewModel.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//

import Foundation
import CoreData
import Foundation

struct PokemonListResponse: Codable {
    let results: [PokemonEntry]
}


class PokemonViewModel: ObservableObject {
    @Published var pokemons: [PokemonEntry] = []
    let context = PersistenceController.shared.container.viewContext

    func fetchPokemons() async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=1000") else {
            print("URL invalide")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            
            // Mise à jour de l'état sur le fil principal
            DispatchQueue.main.async {
                self.pokemons = decodedResponse.results
            }
        } catch {
            print("Erreur lors de la récupération des Pokémon : \(error)")
        }
    }

    
    private func fetchFromAPI() async {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=18") else { return }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedResponse = try JSONDecoder().decode(PokemonListResponse.self, from: data)
            
            DispatchQueue.main.async {
                self.pokemons = decodedResponse.results
                self.saveToCoreData()
            }
        } catch {
            print("Erreur API: \(error)")
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
