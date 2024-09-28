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

        2. Use License
        Permission is granted to temporarily download one copy of the app for personal, non-commercial transitory viewing only.

        3. Disclaimer
        The app is provided on an 'as is' basis. We make no warranties, expressed or implied, and hereby disclaim and negate all other warranties including, without limitation, implied warranties or conditions of merchantability, fitness for a particular purpose, or non-infringement of intellectual property or other violation of rights.

        4. Limitations
        In no event shall we or our suppliers be liable for any damages (including, without limitation, damages for loss of data or profit, or due to business interruption) arising out of the use or inability to use the app.

        5. Revisions and Errata
        The materials appearing in the Zap app could include technical, typographical, or photographic errors. We do not warrant that any of the materials in this app are accurate, complete or current.

        6. Links
        We have not reviewed all of the sites linked to our app and are not responsible for the contents of any such linked site. The inclusion of any link does not imply endorsement by us of the site. Use of any such linked website is at the user's own risk.

        7. Modifications
        We may revise these terms of service for the app at any time without notice. By using this app you are agreeing to be bound by the then current version of these terms of service.

        8. Governing Law
        These terms and conditions are governed by and construed in accordance with the laws of [Your Country/State] and you irrevocably submit to the exclusive jurisdiction of the courts in that State or location.

        Last updated: September 28, 2024
        """
    }
}
