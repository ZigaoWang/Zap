//
//  ImageFullscreenView.swift
//  Zap
//
//  Created by Zigao Wang on 9/21/24.
//

import SwiftUI

struct ImageFullscreenView: View {
    let image: UIImage
    @Binding var isPresented: Bool

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.edgesIgnoringSafeArea(.all)
            
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            Button(action: {
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
            }
        }
    }
}

struct ImageFullscreenView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFullscreenView(image: UIImage(systemName: "photo")!, isPresented: .constant(true))
    }
}
