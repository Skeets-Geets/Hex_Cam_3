//
//  UIImageView+GIF.swift
//  Hex_Cam
//
//  Created by GEET on 9/3/23.
//

import Foundation
import UIKit
import ImageIO

extension UIImageView {
    func loadGif(from name: String, completion: ((Double) -> Void)? = nil) {
        DispatchQueue.global().async {
            if let image = UIImage.gif(name: name),
               let imageData = image.pngData(),
               let source = CGImageSourceCreateWithData(imageData as CFData, nil) {
                let duration = UIImage.gifDuration(source)
                DispatchQueue.main.async {
                    self.image = image
                    completion?(duration)
                }
            }
        }
    }
}

extension UIImage {
    class func gif(name: String) -> UIImage? {
        guard let bundleURL = Bundle.main.url(forResource: name, withExtension: "gif") else {
            print("This image named \(name) doesn't exist!")
            return nil
        }

        guard let imageData = try? Data(contentsOf: bundleURL) else {
            print("Cannot turn image named \(name) into NSData")
            return nil
        }

        let source = CGImageSourceCreateWithData(imageData as CFData, nil)!
        return UIImage.animatedImage(with: source)
    }

    class func animatedImage(with source: CGImageSource, and duration: Double = 3.9) -> UIImage? {
        let count = CGImageSourceGetCount(source)
        let images = (0..<count).compactMap { CGImageSourceCreateImageAtIndex(source, $0, nil) }

        return UIImage.animatedImage(with: images.map { UIImage(cgImage: $0) }, duration: duration)
    }

    class func gifDuration(_ source: CGImageSource) -> Double {
        let count = CGImageSourceGetCount(source)
        var duration = 0.0

        for i in 0..<count {
            if let properties = CGImageSourceCopyPropertiesAtIndex(source, i, nil) as? [String: Any],
               let gifInfo = properties[kCGImagePropertyGIFDictionary as String] as? [String: Any],
               let frameDuration = gifInfo[kCGImagePropertyGIFDelayTime as String] as? Double {
                duration += frameDuration
            }
        }

        return duration
    }
}
