//
//  TermsOfServiceView.swift
//  Zap
//
//  Created by Zigao Wang on 9/28/24.
//

import SwiftUI

struct TermsOfServiceView: View {
    var body: some View {
        ScrollView {
            Text(termsOfService)
                .padding()
        }
        .navigationTitle("Terms of Service")
    }
    
    private var termsOfService: String {
        """
        Terms of Service for Zap App

        1. Acceptance of Terms
        By using the Zap app, you agree to these Terms of Service. If you disagree with any part of the terms, you may not use our app.

        2. Open Source License
        Zap is open-source software, licensed under the GNU General Public License v3.0 (GPL-3.0). You can find the source code on GitHub:
        - App: https://github.com/ZigaoWang/Zap
        - Backend: https://github.com/ZigaoWang/Zap-backend

        3. Third-Party Services
        Zap uses https://uniapi.ai/ as a proxy for OpenAI services. By using Zap, you also agree to comply with UniAPI's terms of service.

        4. Disclaimer
        The app is provided on an 'as is' basis. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

        5. Limitations
        In no event shall we or our suppliers be liable for any damages arising out of the use or inability to use the app.

        6. Modifications
        We may revise these terms of service at any time without notice. By using this app, you are agreeing to be bound by the current version of these terms of service.

        7. Contact
        If you have any questions about these Terms of Service, please contact us at a@zigao.wang.

        Last updated: October 17, 2024
        """
    }
}
