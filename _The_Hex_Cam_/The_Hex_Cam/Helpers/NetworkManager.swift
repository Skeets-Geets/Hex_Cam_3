//
//  NetworkManager.swift
//  Hex_Cam
//
//  Created by GEET on 9/29/23.
//
// THIS CONTAINS ALL OF MY API HANDLING WITH THE COLOR API

import Foundation
import SwiftUI
import Combine

class NetworkManager: ObservableObject {
    @Published var colorName: String = ""
    @Published var colorImage: UIImage?
    @Published var colorInfo: APIColorInfo?

    func fetchColorInfo(for hex: String) {
        let urlString = "https://www.thecolorapi.com/id?hex=\(hex.replacingOccurrences(of: "#", with: ""))"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching color data: \(error!.localizedDescription)")
                return
            }

            do {
                let colorInfo = try JSONDecoder().decode(APIColorInfo.self, from: data)
                DispatchQueue.main.async {
                    self.colorInfo = colorInfo
                    self.colorName = colorInfo.name.value
                    self.downloadImage(from: colorInfo.image.bare)
                }
            } catch {
                print("Error decoding color data: \(error)")
            }
        }.resume()
    }

    private func downloadImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching image data: \(String(describing: error))")
                return
            }

            DispatchQueue.main.async {
                self.colorImage = UIImage(data: data)
            }
        }.resume()
    }
}

struct APIColorInfo: Decodable {
    let name: ColorName
    let image: ColorImage
}

struct ColorName: Decodable {
    let value: String
}

struct ColorImage: Decodable {
    let bare: String
}
