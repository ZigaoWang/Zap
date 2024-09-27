//
//  AppearanceSettingsView.swift
//  Zap
//
//  Created by Zigao Wang on 9/27/24.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @EnvironmentObject var appearanceManager: AppearanceManager
    
    var body: some View {
        Form {
            Section(header: Text("Theme")) {
                Picker("App Theme", selection: $appearanceManager.appTheme) {
                    ForEach(AppearanceManager.AppTheme.allCases, id: \.self) { theme in
                        Text(theme.rawValue.capitalized).tag(theme)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("Accent Color")) {
                ColorPicker("Accent Color", selection: $appearanceManager.accentColor)
                    .onChange(of: appearanceManager.accentColor) { newValue in
                        appearanceManager.accentColorString = newValue.toHex() ?? "blue"
                    }
            }
            
            Section(header: Text("Font Size")) {
                Picker("Font Size", selection: $appearanceManager.fontSize) {
                    ForEach(AppearanceManager.FontSize.allCases, id: \.self) { size in
                        Text(size.rawValue.capitalized).tag(size)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            Section(header: Text("List View Style")) {
                Picker("List View Style", selection: $appearanceManager.listViewStyle) {
                    ForEach(AppearanceManager.ListViewStyle.allCases, id: \.self) { style in
                        Text(style.rawValue.capitalized).tag(style)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
        }
        .navigationTitle("Appearance")
    }
}
