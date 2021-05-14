//
//  LineView.swift
//  
//
//  Created by O'Brien, Patrick on 4/22/21.
//

import SwiftUI

internal struct LineView: View {
    @Binding var displayLine: Bool
    var startPoint: CGPoint
    var endPoint: CGPoint
    var screen = UIScreen.main.bounds
    var gradient: LinearGradient {
        LinearGradient(gradient: Gradient(colors: [.white, Color(red: 10/255, green: 110/255, blue: 209/255)]),
                       startPoint: UnitPoint(x: startPoint.x / screen.width, y: startPoint.y / screen.height),
                       endPoint: UnitPoint(x: endPoint.x / screen.width, y: endPoint.y / screen.height))
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
            .animateOnAppear(animation: Animation.easeInOut(duration: 0.4)) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(Animation.easeInOut(duration: 0.1)) {
                        displayLine = false
                    }
                }
            }
        }
    }
}
