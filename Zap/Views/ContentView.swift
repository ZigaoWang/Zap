//
//  ContentView.swift
//  Zap
//
//  Created by Zigao Wang on 9/18/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = NotesViewModel()
    @StateObject var appearanceManager = AppearanceManager()

    var body: some View {
        HomeView()
            .environmentObject(viewModel)
            .environmentObject(appearanceManager)
            .environment(\.customFontSize, appearanceManager.fontSizeValue)
            .preferredColorScheme(appearanceManager.colorScheme)
            .accentColor(appearanceManager.accentColor)
    }
}
