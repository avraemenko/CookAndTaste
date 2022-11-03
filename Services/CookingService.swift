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
                            print( self.searchResults)
                        }
                    }
                }
            }
            catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
//            let recipeInfo = try await complexNetworkService.perform(.get, RecipeInfoEndpoint(with: "\(recipeIDs.first ?? 0)"), RecipeByID("\(recipeIDs.first ?? 0)"))
           // print(try JSONSerialization.jsonObject(with: recipeInfo!, options: []) as? [String: Any])
        }
    }
    
    struct Result : Codable, Identifiable {
        let id : Int
        let image : String
        let title : String
        let imageType : String
    }
    
    func getRecipe(){
        
    }
}
