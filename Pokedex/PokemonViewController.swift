import UIKit

class PokemonViewController: UIViewController {
    var url: String!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var numberLabel: UILabel!
    @IBOutlet var type1Label: UILabel!
    @IBOutlet var type2Label: UILabel!
    @IBOutlet var catchBtn: UIButton!
    @IBOutlet var spriteImg: UIImageView!
    @IBOutlet var descriptionLabel:UILabel!
    
    // in the beginning we have not caught any pokemon yet
    var isCaught:String = "false"
    
    // capitalizing the pokemon name's first character
    func capitalize(text: String) -> String {
        return text.prefix(1).uppercased() + text.dropFirst()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nameLabel.text = ""
        numberLabel.text = ""
        type1Label.text = ""
        type2Label.text = ""
        descriptionLabel.text = ""
        
        // changing colors for background to have a pokedex look
        catchBtn.backgroundColor = UIColor.white
        catchBtn.layer.cornerRadius = catchBtn.frame.height / 2
        catchBtn.setTitleColor(UIColor.gray, for: UIControl.State.normal)
        
        catchBtn.layer.shadowColor = UIColor.red.cgColor
        catchBtn.layer.shadowOpacity = 6
        
        // image literal for the background
        let back = #imageLiteral(resourceName: "pokedex")
        //setting background with image in back
        self.view.backgroundColor = UIColor(patternImage: back)
        
        // calling func to load pokemon details
        loadPokemon()
        
    }
    
    func loadPokemon() {
        // getting data aboutthe pokemon using API
        URLSession.shared.dataTask(with: URL(string: url)!) { (data, response, error) in
            guard let data = data else {
                return
            }
            
            do {
                // decoding data into a list
                let result = try JSONDecoder().decode(PokemonResult.self, from: data)
                DispatchQueue.main.async {
                    
                    // capitalizing name
                    
                    self.navigationItem.title = self.capitalize(text: result.name)
                    self.nameLabel.text = self.capitalize(text: result.name)
                    // formating the number
                    self.numberLabel.text = String(format: "#%03d", result.id)
                    
                    let url1 = URL(string: result.sprites.front_default)
                    let data1 = try? Data(contentsOf: url1!)
                    self.spriteImg.image = UIImage(data: data1!)
                    
                    // validation to shown correct value for isCaught depending on previously saved state
                    if let status = self.nameLabel.text as String?{
                        if let c = UserDefaults.standard.string(forKey: status) as String? {
                            self.isCaught = c
                        }
                        else
                        {
                            self.isCaught = "false"
                        }
                    }
                    else {
                        // status is null
                        self.isCaught = "false"
                    }
                    
                    // setting button title to Release or Catch depending on previous validation
                    if self.isCaught == "true"{
                        self.catchBtn.setTitle("Release", for: UIControl.State.normal)
                    }
                    else{
                        self.catchBtn.setTitle("Catch", for: UIControl.State.normal)
                    }
                    // populating the types
                    for typeEntry in result.types {
                        if typeEntry.slot == 1 {
                            self.type1Label.text = typeEntry.type.name
                        }
                        else if typeEntry.slot == 2 {
                            self.type2Label.text = typeEntry.type.name
                        }
                    }
                    self.loadDescription(num: result.id)
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    func loadDescription(num: Int)
    {
        // loading the description calling a different api pokemon species
        URLSession.shared.dataTask(with: URL(string: "https://pokeapi.co/api/v2/pokemon-species/\(num)")!) { (dat, res, err) in
            guard let des = dat else {
                return
            }
            do {
                // decoding the json into a list
                let result = try JSONDecoder().decode(PokemonSpecies.self, from: des)
                DispatchQueue.main.async {
                    var descText : String = ""
                    // retrieving the data for only English and the pokemon version I chose was Ruby
                    for flavor in result.flavor_text_entries {
                        if flavor.language.name == "en" && flavor.version.name == "ruby"
                        {
                            descText+=" \(flavor.flavor_text)"
                        }
                    }
                    // trying to clean up the way the description comes from the API
                    self.descriptionLabel.text = descText.trimmingCharacters(in: .whitespacesAndNewlines)
                }
            }
            catch let error {
                print(error)
            }
        }.resume()
    }
    
    @IBAction func toggleCatch() {
        // gotta catch 'em all!
        if(isCaught == "true"){
            // changing the button title depending of the current isCaught value and updating userdefaults value as well for enforcing state when reopening the app
            catchBtn.setTitle("Catch", for: UIControl.State.normal)
            UserDefaults.standard.set("false",forKey: "\(String(self.nameLabel.text!))")
            isCaught = "false"
        }
        else{
            catchBtn.setTitle("Release", for: UIControl.State.normal)
            UserDefaults.standard.set("true",forKey: "\(String(self.nameLabel.text!))")
            isCaught = "true"
        }
    }
}
