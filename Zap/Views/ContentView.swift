//
//  ContentView.swift
//  Zap
//
//  Created by Zigao Wang on 9/18/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("主页")
                }
            
            SavedNotesView()
                .tabItem {
                    Image(systemName: "tray.full.fill")
                    Text("已保存")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(NotesViewModel())
    }
}
