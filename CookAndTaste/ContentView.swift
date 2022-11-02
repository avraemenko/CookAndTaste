//
//  ContentView.swift
//  CookAndTaste
//
//  Created by Kateryna Avramenko on 02.11.22.
//

import SwiftUI

struct ContentView: View {
    
    @State private var searchText = ""
    let cookingService = CookingService()
    
    var body: some View {
        VStack {
            NavigationView {
                Text("Searching for \(searchText)")
                    .searchable(text: $searchText)
                    .navigationTitle("Searchable Example")
            }
            .padding()
        }
    }
    
    struct ContentView_Previews: PreviewProvider {
        static var previews: some View {
            ContentView()
        }
    }
}
