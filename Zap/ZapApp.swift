//
//  ZapApp.swift
//  Zap
//
//  Created by Zigao Wang on 9/18/24.
//

import SwiftUI

@main
struct ZapApp: App {
    @StateObject private var viewModel = NotesViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
