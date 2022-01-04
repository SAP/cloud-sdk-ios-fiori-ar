//
//  UIImage+Extensions.swift
//
//
//  Created by O'Brien, Patrick on 1/4/22.
//

import UIKit

extension UIImage {
    func resize(to percent: CGFloat) -> UIImage? {
        let newSize = CGSize(width: self.size.width * percent, height: self.size.height * percent)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 1.0)
        self.draw(in: CGRect(origin: .zero, size: newSize))
        defer { UIGraphicsEndImageContext() }
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
