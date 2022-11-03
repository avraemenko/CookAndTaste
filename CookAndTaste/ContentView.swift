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
                    Text("Searching for \(searchText)")
                        .searchable(text: $searchText)
                        .navigationTitle("Cook book")
                        .onChange(of: searchText, perform: { newValue in
                            Task {
                                await cookingService.fetchData(query: newValue)
                            }
                        })
                    
                    List(cookingService.searchResults, id: \.id) { result in
                        VStack {
                            Text("\(result.title)")
                            AsyncImage(url: URL(string: "\(result.image)"))
                        }
                    }
                    .padding()
                }
                
            }
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
