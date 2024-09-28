//
//  AboutHelpView.swift
//  Zap
//
//  Created by Zigao Wang on 9/28/24.
//

import SwiftUI

struct AboutHelpView: View {
    @Environment(\.openURL) var openURL
    
    var body: some View {
        List {
            Section(header: Text("About")) {
                HStack {
                    Text("App Version")
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown")
                        .foregroundColor(.secondary)
                }
                
                NavigationLink("Terms of Service", destination: TermsOfServiceView())
                NavigationLink("Privacy Policy", destination: PrivacyPolicyView())
            }
            
            Section(header: Text("Help")) {
                Button("FAQs") {
                    if let url = URL(string: "https://github.com/ZigaoWang/Zap") {
                        openURL(url)
                    }
                }
                
                Button("Contact Support") {
                    if let url = URL(string: "mailto:a@zigao.wang") {
                        openURL(url)
                    }
                }
            }
            
            Section(header: Text("Feedback")) {
                Button("Rate the App") {
                    if let url = URL(string: "https://apps.apple.com/app/idAPP_ID") {
                        openURL(url)
                    }
                }
            }
            
            Section(header: Text("Credits")) {
                Button("Created by Zigao Wang") {
                    openURL(URL(string: "https://zigao.wang")!)
                }
                
                Button("Open Source on GitHub") {
                    openURL(URL(string: "https://github.com/ZigaoWang/Zap")!)
                }
            }
        }
        .navigationTitle("About & Help")
    }
}
