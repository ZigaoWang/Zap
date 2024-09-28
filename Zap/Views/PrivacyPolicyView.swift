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

        1. Information Collection and Use
        We collect several different types of information for various purposes to provide and improve our Service to you.

        2. Types of Data Collected
        Personal Data
        While using our Service, we may ask you to provide us with certain personally identifiable information that can be used to contact or identify you ("Personal Data"). Personally identifiable information may include, but is not limited to:
        - Email address
        - First name and last name
        - Cookies and Usage Data

        Usage Data
        We may also collect information that your browser sends whenever you visit our Service or when you access the Service by or through a mobile device ("Usage Data").

        3. Use of Data
        Zap uses the collected data for various purposes:
        - To provide and maintain our Service
        - To notify you about changes to our Service
        - To allow you to participate in interactive features of our Service when you choose to do so
        - To provide customer support
        - To gather analysis or valuable information so that we can improve our Service
        - To monitor the usage of our Service
        - To detect, prevent and address technical issues

        4. Transfer of Data
        Your information, including Personal Data, may be transferred to — and maintained on — computers located outside of your state, province, country or other governmental jurisdiction where the data protection laws may differ from those of your jurisdiction.

        5. Disclosure of Data
        We may disclose your Personal Data in the good faith belief that such action is necessary to:
        - To comply with a legal obligation
        - To protect and defend the rights or property of Zap
        - To prevent or investigate possible wrongdoing in connection with the Service
        - To protect the personal safety of users of the Service or the public
        - To protect against legal liability

        6. Security of Data
        The security of your data is important to us but remember that no method of transmission over the Internet or method of electronic storage is 100% secure. While we strive to use commercially acceptable means to protect your Personal Data, we cannot guarantee its absolute security.

        7. Changes to This Privacy Policy
        We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.

        8. Contact Us
        If you have any questions about this Privacy Policy, please contact us:
        - By email: a@zigao.wang

        Last updated: September 28, 2024
        """
    }
}
