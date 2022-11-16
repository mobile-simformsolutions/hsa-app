//
//  UImageExtension.swift
//

import UIKit
import SwiftUI

extension UIImage {
    
    func compressImageToSize() -> Data? {
        let minFileSize = 5 * 1000 * 1000 // 5 MB
        var compressionQuality: CGFloat = 1.0
        var data: Data? = self.jpegData(compressionQuality: compressionQuality)
        while data?.count ?? 0 > minFileSize {
            compressionQuality -= 1.0
            data = self.jpegData(compressionQuality: compressionQuality)
        }
        return data
    }
}

extension Image {
    
    func onboardingStyle(width: CGFloat = 250, height: CGFloat = 250) -> some View {
        return self.resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height, alignment: .center)
    }
    
    func onboardingPrimaryStyle() -> some View {
        return self.resizable()
            .frame(width: 226, height: 226, alignment: .center)
            .padding(.top, 20)
    }
}
