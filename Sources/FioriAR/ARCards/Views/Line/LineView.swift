//
//  LineView.swift
//
//
//  Created by O'Brien, Patrick on 4/22/21.
//

import FioriThemeManager
import SwiftUI

struct LineView: View {
    @State private var opacity: Double = 0
    
    @Binding var displayLine: Bool
    var startPoint: CGPoint
    var endPoint: CGPoint
    var screen = UIScreen.main.bounds
    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [Color.white, Color.preferredColor(.tintColor, background: .lightConstant)]),
                       startPoint: UnitPoint(x: self.startPoint.x / self.screen.width, y: self.startPoint.y / self.screen.height),
                       endPoint: UnitPoint(x: self.endPoint.x / self.screen.width, y: self.endPoint.y / self.screen.height))
    }
    
    internal init(displayLine: Binding<Bool>, startPoint: CGPoint, endPoint: CGPoint) {
        self._displayLine = displayLine
        self.startPoint = startPoint
        self.endPoint = endPoint
    }
    
    internal var body: some View {
        if displayLine {
            Path { path in
                path.move(to: endPoint)
                path.addLine(to: startPoint)
            }
            .stroke(gradient, lineWidth: 3)
            .opacity(opacity)
            .animateOnAppear(animation: Animation.easeIn(duration: 0.2)) {
                opacity = 1
                // Delay Fade Out
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(Animation.easeOut(duration: 0.2)) {
                        opacity = 0
                    }
                    // Delay reseting Displaying line or else the animation stops recieving updated positions appearing to be frozen
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        displayLine = false
                    }
                }
            }
        }
    }
}
