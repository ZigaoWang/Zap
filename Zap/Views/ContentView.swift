//
//  ContentView.swift
//  Zap
//
//  Created by Zigao Wang on 9/18/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = NotesViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
            
            SavedNotesView()
                .tabItem {
                    Image(systemName: "folder.fill")
                    Text("Saved")
                }
        }
        .environmentObject(viewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
