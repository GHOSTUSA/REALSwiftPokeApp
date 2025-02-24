//
//  PokemonEntry.swift
//  REALSwiftPokeApp
//
//  Created by Ethan DAHI-GERMAIN on 2/17/25.
//
import Foundation
import CoreData

struct PokemonEntry: Codable, Identifiable {
    var id: Int {
        Int(url.split(separator: "/").last ?? "0") ?? 0
    }
    let name: String
    let url: String

    func toPokemon(with details: PokemonDetail, isFavorite: Bool = false) -> Pokemon {
        return Pokemon(
            id: id,
            name: name.capitalized,
            image: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(id).png",
            types: details.types.map { $0.type.name }.joined(separator: ", "),
            stats: Stats(
                hp: details.stats.first(where: { $0.stat.name == "hp" })?.baseStat ?? 0,
                attack: details.stats.first(where: { $0.stat.name == "attack" })?.baseStat ?? 0,
                defense: details.stats.first(where: { $0.stat.name == "defense" })?.baseStat ?? 0,
                speed: details.stats.first(where: { $0.stat.name == "speed" })?.baseStat ?? 0
            ),
            isFavorite: isFavorite
        )
    }
}

