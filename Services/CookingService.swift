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
    
    @Published private(set) var recipeIDs = [Int]()
    @Published private(set) var searchResults = [Result]()
    
    init() {
        let networkService = AlamoNetworking<RecipesEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)
        let complexNetworkService = AlamoNetworking<RecipeInfoEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)
        
        Task {
            let data = try await networkService.perform(.get, .complexSearch, SearchForRecipe("Pasta with tomatoes"))
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any], let results = json["results"] as? NSArray {
                    //let search = try JSONDecoder().decode(Result.self, from: results)
                    //print(search)
                    
                    for (idx, obj) in results.enumerated() {
                        let result = obj as? [String: Any]
                        let id = result?["id"] as? Int
                        recipeIDs.insert(id ?? 0, at: idx)
                    }
                }
            }
            catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
            let recipeInfo = try await complexNetworkService.perform(.get, RecipeInfoEndpoint(with: "\(recipeIDs.first ?? 0)"), RecipeByID("\(recipeIDs.first ?? 0)"))
           // print(try JSONSerialization.jsonObject(with: recipeInfo!, options: []) as? [String: Any])
        }
        
    }
    
    struct Result : Codable {
        let id : Int
        let image : String
        let title : String
        let imageType : String
    }
    
    func getRecipe(){
        
    }
}
