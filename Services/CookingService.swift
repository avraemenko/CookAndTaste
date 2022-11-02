//
//  CookingService.swift
//  CookAndTaste
//
//  Created by Kateryna Avramenko on 02.11.22.
//

import Foundation

class CookingService {
    
    let headers = [
        "content-type": "application/x-www-form-urlencoded",
        "X-RapidAPI-Key": "d2efa304d8msh04d7681d1a312e6p117b8ajsn5917c738bc8f",
        "X-RapidAPI-Host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com"
    ]
    
    init() {
        let networkService = AlamoNetworking<RecipesEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)
        
        Task {
            let data = try await networkService.perform(.get, .complexSearch, SearchForRecipe("Pasta with tomatoes"))
            print(try! JSONSerialization.jsonObject(with: data!))
        }
    }
    
    
}
