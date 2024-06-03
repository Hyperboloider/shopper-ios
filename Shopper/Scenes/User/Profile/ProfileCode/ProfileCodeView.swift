//
//  ProfileCodeView.swift
//  Shopper
//
//  Created by Гіяна Князєва on 31.12.2022.
//

import SwiftUI

struct ProfileCodeView: View {
    
    @StateObject var viewModel: ProfileCodeViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        if let uiImage = viewModel.uiImage {
            VStack {
                BarCodeView(uiImage: uiImage)
                    .scaleEffect(x: 0.66, y: 0.66)
                    .frame(height: 100)
                    .if(colorScheme == .dark) { $0.colorInvert() }
                
                Text(viewModel.id)
                    .font(.system(.body, design: .monospaced, weight: .semibold))
            }
            .rotationEffect(.degrees(90))
        }
    }
}

fileprivate struct BarCodeView: UIViewRepresentable {
    let uiImage: UIImage
    func makeUIView(context: Context) -> UIImageView {
        UIImageView()
    }

    func updateUIView(_ uiView: UIImageView, context: Context) {
        uiView.image = uiImage
    }
}

struct ProfileCodeView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileCodeView(viewModel: ProfileCodeViewModel(string: "234dew"))
    }
}
