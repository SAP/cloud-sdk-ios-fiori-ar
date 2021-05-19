//
//  DownloadsView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/6/21.
//

import SwiftUI
import UIKit

struct DownloadsView: View {
    @State var images: [ImageAttributes] = [ImageAttributes(id: 0, imageName: "qrImage", ext: "png", size: CGSize(width: 26, height: 35))]
    
    var body: some View {
        VStack(spacing: 15) {
            ScrollView(showsIndicators: false) {
                ForEach(images) { image in
                    VStack {
                        ImageCard(imageName: image.imageName, imageExtension: image.ext)
                        Text("Width: \(Int(image.size.width)), Height: \(Int(image.size.height)) cm")
                    }
                }
            }
            Text("Tap to share Image")
        }
    }
}

struct ImageAttributes: Identifiable {
    var id: Int
    var imageName: String
    var ext: String
    var size: CGSize
}

struct ImageCard: View {
    let imageName: String
    let imageExtension: String
    @State var presentSheet = false
    
    var body: some View {
        Image(imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: UIScreen.main.bounds.width, height: 225, alignment: .center)
            .padding()
            .onTapGesture {
                // Simple Check to prevent potential crash
                if let _ = FileManager.default.getImagePath(for: imageName, ext: imageExtension) {
                    presentSheet = true
                }
            }
            .sheet(isPresented: $presentSheet) {
                ActivityViewController(activityItems: [FileManager.default.getImagePath(for: imageName, ext: imageExtension)!])
            }
    }
}

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}

extension FileManager {
    func getImagePath(for name: String, ext: String) -> URL? {
        guard let resourcePath = Bundle.main.path(forResource: name, ofType: ext) else { return nil }
        return URL(fileURLWithPath: resourcePath)
    }
}
