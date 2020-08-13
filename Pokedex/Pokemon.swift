import Foundation

struct PokemonListResults: Codable {
    var results: [PokemonListResult]
}

struct PokemonListResult: Codable {
    let name: String
    let url: String
}

struct PokemonResult: Codable {
    let id: Int
    let name: String
    let types: [PokemonTypeEntry]
    let sprites: Sprites
}

struct PokemonTypeEntry: Codable {
    let slot: Int
    let type: PokemonType
}

struct PokemonType: Codable {
    let name: String
}

struct Sprites: Codable {
    let front_default: String
}

struct PokemonSpecies: Codable {
    let flavor_text_entries: [FlavorEntry]
}
struct FlavorEntry: Codable {
    let flavor_text : String
    let language: Lang
    let version : Version
}
struct Lang: Codable
{
    let name: String
    let url: String
}
struct Version: Codable
{
    let name: String
    let url: String
}

