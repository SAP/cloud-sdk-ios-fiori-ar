//
//  PickerSelectionView.swift
//
//
//  Created by O'Brien, Patrick on 1/4/22.
//

import SwiftUI

enum ImagePickerSource {
    case camera
    case photoLibrary
}

struct PickerSelectionView: View {
    @Binding var uiImage: UIImage?
    var imageSource: ImagePickerSource
    
    var body: some View {
        switch imageSource {
        case .camera:
            ImageCameraPickerView(uiImage: $uiImage)
        case .photoLibrary:
            ImagePickerView(uiImage: $uiImage)
        }
    }
}
