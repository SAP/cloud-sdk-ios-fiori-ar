//
//  ARContainer.swift
//  ARTestApp
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import RealityKit
import SwiftUI

struct ARContainer: UIViewRepresentable {
    var arStorage: ARManager
    
    func makeUIView(context: Context) -> ARView {
        self.arStorage.arView ?? ARView(frame: .zero)
    }

    func updateUIView(_ arView: ARView, context: Context) {}
}

typealias AnchorID = UUID
