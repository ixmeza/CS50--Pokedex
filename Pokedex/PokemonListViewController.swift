import UIKit

class PokemonListViewController: UITableViewController , UISearchBarDelegate{
    //creating variables to store decoded data and aux lists for filtering
    var pokemon: [PokemonListResult] = []
    var pok:[PokemonListResult] = []
    var aux:[PokemonListResult] = []
    
    @IBOutlet var searchBar:UISearchBar!
    
    //capitalizing first character
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        
        // Retrieving the pokemons list data using the POKEAPI URL
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=151") else{
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                return
            }
            // parsing the JSON content to display it on the cells
            do {
                let entries = try JSONDecoder().decode(PokemonListResults.self, from: data)
                self.pokemon = entries.results
                self.aux = self.pokemon
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pokemon.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PokemonCell", for: indexPath)
        cell.textLabel?.text = capitalize(text: pokemon[indexPath.row].name)
        return cell
    }
    //linking pokemonview controller using the chevron to be clicked to display pokemon details
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowPokemonSegue",
            let destination = segue.destination as? PokemonViewController,
            let index = tableView.indexPathForSelectedRow?.row {
            destination.url = pokemon[index].url
        }
    }
    
    //adding a listener to the search bar at the top to make sure to manipulate data depending on the results from the API
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //validating for empty search
        var isSearchBarEmpty: Bool {
            return searchBar.text?.isEmpty ?? true
        }
        //if search bar is not empty then we need to manipulate the data
        if !isSearchBarEmpty{
            if searchText == ""{
                //pok is equal to an aux var that contains the results from all pokemons available form the API
                pok = aux
            }
            else
            {
                //filtering our pok list to only display those which contain the text entered in the search bar
                pok = aux.filter{$0.name.lowercased().contains(searchText.lowercased())}
            }
            self.pokemon = pok
            //reloading so view display filtered data
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        else{
            self.pokemon = aux
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
