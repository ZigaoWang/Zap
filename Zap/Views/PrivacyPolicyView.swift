//
//  PrivacyPolicyView.swift
//  Zap
//
//  Created by Zigao Wang on 9/28/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            Text(privacyPolicy)
                .padding()
        }
        .navigationTitle("Privacy Policy")
    }
    
    private var privacyPolicy: String {
        """
        Privacy Policy for Zap App

        1. Information Collection
        At present, Zap does not collect any personal information from its users. We are committed to protecting your privacy and ensuring a secure user experience.

        2. Third-Party Services
        We use https://uniapi.ai/ as a proxy for OpenAI services. Please refer to UniAPI's privacy policy for information on how they handle data.

        3. Open Source
        Zap is an open-source project. All of our code is available under the GNU General Public License v3.0 (GPL-3.0) and can be found on GitHub:
        - App: https://github.com/ZigaoWang/Zap
        - Backend: https://github.com/ZigaoWang/Zap-backend

        4. Future Updates
        This privacy policy is a work in progress. As we develop our app further, we may update this policy to reflect any changes in data handling. We will notify users of any significant changes.

        5. Contact Us
        If you have any questions about this Privacy Policy, please contact us at a@zigao.wang.

        Last updated: October 17, 2024
        """
    }
}
