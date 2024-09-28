//
//  ContentView.swift
//  Zap
//
//  Created by Zigao Wang on 9/18/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: NotesViewModel
    @EnvironmentObject var appearanceManager: AppearanceManager
    @EnvironmentObject var mediaQualitySettings: MediaQualitySettings

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
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gear")
                    Text("Settings")
                }
        }
        .environment(\.customFontSize, appearanceManager.fontSizeValue)
        .preferredColorScheme(appearanceManager.colorScheme)
        .accentColor(appearanceManager.accentColor)
    }
}
