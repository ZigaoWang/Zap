//
//  ZapApp.swift
//  Zap
//
//  Created by Zigao Wang on 9/18/24.
//

import SwiftUI

@main
struct ZapApp: App {
    @StateObject var viewModel = NotesViewModel()
    @StateObject var appearanceManager = AppearanceManager()
    @StateObject var mediaQualitySettings = MediaQualitySettings()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
                .environmentObject(appearanceManager)
                .environmentObject(mediaQualitySettings)
        }
    }
}
