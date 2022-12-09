//
//  ContentView.swift
//  CookAndTaste
//
//  Created by Kateryna Avramenko on 02.11.22.
//

import SwiftUI

struct ContentView: View {
    @State private var searchText = ""
    @ObservedObject var cookingService = CookingService()

    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("")
                        .searchable(text: $searchText)
                        .navigationTitle("Cook book")
                        .onChange(of: searchText, perform: { newValue in
                            Task {
                                cookingService.fetchData(query: newValue)
                            }
                        })
                        .onChange(of: searchText) { _ in
                            Task {
                                cookingService.classifyCuisine(parameter: searchText, ingredients: cookingService.ingredients)
                                cookingService.guessNutritionByDishName(parameter: searchText)
                            }
                        }
                    VStack {
                        NavigationLink(
                            destination: SecondView(nutritionData: cookingService.nutritionData.first)) {
                                Text("Guess Nutrition")
                            }
                    }
                    List(cookingService.searchResults, id: \.id) { result in
                        NavigationLink {
                            ScrollView {
                                VStack {
                                    Text("\(result.title)")
                                        .bold()
                                        .foregroundColor(.mint)
                                        .onAppear {
                                            Task {
                                                cookingService.getRecipe(parameter: String(result.id))
                                            }
                                        }
                                    AsyncImage(url: URL(string: "\(result.image)"))
                                    Text("\(cookingService.recipe.instructions)")
                                    Text("Ready in \(cookingService.recipe.readyInMinutes) minutes")
                                        .bold()
                                        .foregroundColor(.mint)
                                    Text("Cuisine - \(cookingService.cuisine)")
                                }
                            }
                        } label: {
                            VStack {
                                Text("\(result.title)")
                                AsyncImage(url: URL(string: "\(result.image)"))
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }
}

struct SecondView: View {
    let nutritionData: Nutrition?

    var body: some View {
        if let data = nutritionData {
            VStack {
                Text("Nutrition: ")
                Text("Fat - \(data.fat.value)")
                Text("Protein - \(data.protein.value)")
                Text("Carbs - \(data.carbs.value)")
            }
            .padding()
            .font(.headline)
            .border(Color.gray, width: 0.5)
        } else {
            EmptyView()
        }
    }
}
