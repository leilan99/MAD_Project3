//
//  ContentView.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                HomeView()
            }

            Tab("Browse", systemImage: "magnifyingglass") {
                BrowseView()
            }

            Tab("Random", systemImage: "dice.fill") {
                RandomDinnerView()
            }

            Tab("My Cookbook", systemImage: "book.fill") {
                CookbookView()
            }
        }
        .tint(.orange)
    }
}

#Preview {
    ContentView()
        .environment(CookbookStore())
}
