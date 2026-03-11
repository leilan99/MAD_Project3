//
//  recipeMakerApp.swift
//  recipeMaker
//
//  Created by Leila Nunez on 3/9/26.
//

import SwiftUI

@main
struct recipeMakerApp: App {
    @State private var cookbookStore = CookbookStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(cookbookStore)
        }
    }
}
