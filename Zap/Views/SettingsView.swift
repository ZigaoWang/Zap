//
//  SettingsView.swift
//  Zap
//
//  Created by Zigao Wang on 9/27/24.
//

import SwiftUI

struct SettingsView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: AppearanceSettingsView()) {
                    SettingsRowView(title: "Appearance", icon: "paintbrush.fill")
                }
                NavigationLink(destination: MediaQualitySettingsView()) {
                    SettingsRowView(title: "Media Quality", icon: "camera.fill")
                }
                NavigationLink(destination: AboutHelpView()) {
                    SettingsRowView(title: "About & Help", icon: "info.circle.fill")
                }
            }
            .navigationTitle("Settings")
        }
    }
}

struct SettingsRowView: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(title)
        }
    }
}
