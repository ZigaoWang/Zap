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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
