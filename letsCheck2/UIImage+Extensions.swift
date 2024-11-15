//
//  UIImage+Extensions.swift
//  letsCheck2
//
//  Created by iOS on 15/11/24.
//

import UIKit

extension UIImage {
    /// Converts the image to a Base64-encoded string
    func toBase64() -> String? {
        guard let imageData = self.jpegData(compressionQuality: 0.8) else { return nil }
        return imageData.base64EncodedString()
    }

    /// Converts a Base64-encoded string back to a UIImage
    static func fromBase64(_ base64String: String) -> UIImage? {
        guard let imageData = Data(base64Encoded: base64String) else { return nil }
        return UIImage(data: imageData)
    }

    /// Resizes the image to the specified size
    func resizeImage(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        self.draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
