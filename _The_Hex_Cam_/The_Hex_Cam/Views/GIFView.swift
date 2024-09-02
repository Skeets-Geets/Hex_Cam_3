//
//  GIFView.swift
//  Hex_Cam
//
//  Created by GEET on 9/6/23.
//

import Foundation
import SwiftUI
import UIKit

struct GIFView: UIViewRepresentable {
    var name: String

    func makeUIView(context: UIViewRepresentableContext<GIFView>) -> UIView {
        let view = UIView()

        let imageView = UIImageView()
        imageView.loadGif(from: name)

        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GIFView>) {}
}
