//
//  CookingService.swift
//  CookAndTaste
//
//  Created by Kateryna Avramenko on 02.11.22.
//

import Foundation

class CookingService: ObservableObject {
    
    let headers = [
        "content-type": "application/x-www-form-urlencoded",
        "X-RapidAPI-Key": "d2efa304d8msh04d7681d1a312e6p117b8ajsn5917c738bc8f",
        "X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    ]
    
    private(set) var recipeIDs = [Int]()
    @Published private(set) var searchResults = [Result]()
    @Published var recipe = RecipeInfo(id: 0, image: "", instructions: "", readyInMinutes: 0)
    
    lazy private var networkService = AlamoNetworking<RecipesEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)
    lazy private var complexNetworkService = AlamoNetworking<RecipeInfoEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)
    
    init() {
    }
    
    public func fetchData(query : String) async {
        Task {
            let data = try await networkService.perform(.get, .complexSearch, SearchForRecipe(query))
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any], let results = json["results"] as? NSArray {
                    DispatchQueue.main.async {
                        self.searchResults = []
                    }
                    for obj in results {
                        let result = obj as? [String: Any]
                        guard let id = result?["id"] as? Int,
                              let image = result?["image"] as? String,
                              let imageType = result?["imageType"] as? String,
                              let title = result?["title"] as? String
                        else { continue }
                        DispatchQueue.main.async {
                            self.searchResults.append(Result(id: id, image: image, title: title, imageType: imageType))
                        }
                    }
                }
            }
            catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    func getRecipe(parameter : String){
        Task{
            let data = try await complexNetworkService.perform(.get, RecipeInfoEndpoint(with: parameter), RecipeByID(parameter))
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                    guard let id = json["id"] as? Int,
                          let image =  json["image"] as? String,
                          let instructions = json["instructions"] as? String,
                          let readyInMinutes = json["readyInMinutes"] as? Int
                    else { return }
                    DispatchQueue.main.async {
                        self.recipe = RecipeInfo(id: id, image: image, instructions: instructions, readyInMinutes: readyInMinutes)
                    }
                }
            }
            catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }
    
    struct RecipeInfo : Codable, Identifiable {
        let id: Int
        let image : String
        let instructions : String
        let readyInMinutes : Int
    }
    
    struct Result : Codable, Identifiable {
        let id : Int
        let image : String
        let title : String
        let imageType : String
    }
}
