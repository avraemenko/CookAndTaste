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
    public var ingredients = ""
    @Published private(set) var searchResults = [Result]()
    @Published var recipe = RecipeInfo(id: 0, image: "", instructions: "", readyInMinutes: 0)
    @Published var nutritionData = [Nutrition]()
    @Published var cuisine = ""

    private lazy var networkService = AlamoNetworking<RecipesEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)
    private lazy var complexNetworkService = AlamoNetworking<RecipeInfoEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)

    private lazy var complex2NetworkService = AlamoNetworking<GuessNutritionEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)

    private lazy var complex3NetworkService = AlamoNetworking<ClassifyCuisineEndpoint>("https://spoonacular-recipe-food-nutrition-v1.p.rapidapi.com", headers: headers)

    init() {}

    public func fetchData(query: String)  {
        Task {
            let data = try await networkService.perform(.get, .complexSearch, SearchForRecipe(query))
            do {
                if let correctData = data, let json = try JSONSerialization.jsonObject(with: correctData, options: []) as? [String: Any], let results = json["results"] as? NSArray {
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

    func getRecipe(parameter: String) {
        Task {
            let data = try await complexNetworkService.perform(.get, RecipeInfoEndpoint(with: parameter), RecipeByID(parameter))
            do {
                if let correctData = data, let json = try JSONSerialization.jsonObject(with: correctData, options: []) as? [String: Any] {
                    guard let id = json["id"] as? Int,
                          let image = json["image"] as? String,
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

    func guessNutritionByDishName(parameter: String) {
        Task {

            do {
                guard let data = try await complex2NetworkService.perform(.get, GuessNutritionEndpoint(), GuessNutrition(parameter)) else { return }
                let nutrition: Nutrition = try JSONDecoder().decode(Nutrition.self, from: data)
                DispatchQueue.main.async {
                    self.nutritionData.append(nutrition)
                }
            }
            catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }

    func classifyCuisine(parameter: String, ingredients: String) {
        Task {

            guard let data = try await complex3NetworkService.perform(.post, ClassifyCuisineEndpoint(), ClassifyCuisine(parameter, ingredients)) else { return }
            do {
                let cuisine: Cuisine = try JSONDecoder().decode(Cuisine.self, from: data)
                DispatchQueue.main.async {
                    self.cuisine = cuisine.cuisine
                }
            }
            catch let error as NSError {
                print("Failed to load: \(error.localizedDescription)")
            }
        }
    }
}

// for decoding recipe

struct RecipeInfo: Codable, Identifiable {
    let id: Int
    let image: String
    let instructions: String
    let readyInMinutes: Int
}

struct Result: Codable, Identifiable {
    let id: Int
    let image: String
    let title: String
    let imageType: String
}

// for decoding guess nutrition

struct Nutrition: Codable {
    let calories: NutritionDetails
    let fat: NutritionDetails
    let protein: NutritionDetails
    let carbs: NutritionDetails
    let recipesUsed: Int
}

struct NutritionDetails: Codable {
    let confidenceRange95Percent: StandardDeviation
    let standardDeviation: Double
    let unit: String
    let value: Int
}

struct StandardDeviation: Codable {
    let max: Double
    let min: Double
}

// for decoding classify cuisine

struct Cuisine: Codable {
    let cuisine: String
}
