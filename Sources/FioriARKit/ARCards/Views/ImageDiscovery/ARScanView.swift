//
//  SwiftUIView.swift
//  
//
//  Created by O'Brien, Patrick on 4/8/21.
//

import SwiftUI

public struct ARScanView: View {
    var image: Image
    @Binding var anchorPosition: CGPoint?
    
    public var body: some View {
        ZStack {
            
            if anchorPosition != nil {
                ImageMatchedView(anchorPosition: $anchorPosition)
            } else {
                CollapsingView(image: image)
            }
            
        }
        .animation(.easeInOut(duration: 1.2), value: anchorPosition)
    }
}

private struct CollapsingView: View {
    var image: Image
    @State private var isScanning: Bool = false
    @Namespace var nameSpace
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .cornerRadius(isScanning ? 8: 0)
                .matchedGeometryEffect(id: isScanning ? "image": "background", in: nameSpace, isSource: false)
            
            if isScanning {
                ScanGuide()
            }

            CollapsingBodyView(image: image, isScanning: $isScanning, nameSpace: nameSpace)
            ImagePreviewView(image: image, isScanning: $isScanning, nameSpace: nameSpace)
        }
        .transition(.opacity)
    }
}


private struct CollapsingBodyView: View {
    var image: Image
    @Binding var isScanning: Bool
    
    var nameSpace: Namespace.ID
    
    var body: some View {
        VStack {
            image
                .resizable()
                .cornerRadius(8)
                .padding(.all, 8)
                .scaledToFit()
                .background(
                    ScanGuideCorners()
                        .stroke(isScanning ? Color.clear: Color.white, lineWidth: 2)
                )
                .matchedGeometryEffect(id: isScanning ? "image": "body", in: nameSpace,  isSource: false)
                .padding(.horizontal, 56)
                .padding(.top, 216)
                .allowsHitTesting(isScanning)
                .onTapGesture(perform: buttonAction)
            
            if !isScanning {
                Text("Point your camera at this image to start augmented reality experience")
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 80)
                    .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.15)))
                

                Button(action: { buttonAction() }, label: {
                    Text("Begin Scan")
                        .frame(width: 201, height: 40)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 5)
                        )
                })
                .padding(.bottom, 216)
                .transition(AnyTransition.opacity.animation(.easeInOut(duration: 0.15)))
            }
        }
    }
    
    func buttonAction() {
        withAnimation(.interpolatingSpring(mass: 2, stiffness: 700, damping: 52)) {
            isScanning.toggle()
        }
    }
}

private struct ImagePreviewView: View {
    var image: Image
    @Binding var isScanning: Bool
    
    var nameSpace: Namespace.ID
    
    var body: some View {
        if isScanning {
            VStack {
                Spacer()
                image
                    .resizable()
                    .cornerRadius(8)
                    .padding(.all, 8)
                    .scaledToFit()
                    .matchedGeometryEffect(id: "image", in: nameSpace, properties: .frame)
                    .padding(.bottom, 34)
                    .padding(.horizontal, 136)
                    .hidden()
            }
        }
    }
}

private struct ScanGuide: View {
    @State var scale: CGFloat = 1
    
    var body: some View {
        Image(systemName: "plus")
            .font(.system(size: 22))
            .foregroundColor(.white)
            .background(
                ScanGuideCorners()
                    .stroke(Color.white, lineWidth: 2)
                    .frame(width: 80, height: 80, alignment: .center)
            )
            .scaleEffect(scale)
            .animateOnAppear(animation: Animation.easeInOut(duration: 0.2)) {
                scale = 1.5
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(Animation.easeInOut(duration: 0.2)) {
                        scale = 1
                    }
                }
            }
    }
}

private struct ImageMatchedView: View {
    @Binding var anchorPosition: CGPoint?
    @State var opacity: Double = 0
    
    var body: some View {
        Image(systemName: "checkmark.circle.fill")
            .font(.system(size: 38))
            .foregroundColor(.white)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0/255, green: 90/255, blue: 38/255, opacity: 0.6))
                    .frame(width: 120, height: 120)
                    .padding(.all, 3)
                    .background(
                        ScanGuideCorners()
                            .stroke(Color.white, lineWidth: 2)
                    )
            )
            .position(anchorPosition!)
            .animation(nil, value: anchorPosition!)
            .opacity(opacity)
            .animateOnAppear(animation: Animation.easeInOut(duration: 1)) {
                opacity = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation(Animation.easeInOut(duration: 1)) {
                        opacity = 0
                    }
                }
            }
    }
}

internal struct ScanGuideCorners: Shape {
    
    public init() {}
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        // Top left Corner
        path.move(to: CGPoint(x: 0, y: 24))
        path.addLine(to: CGPoint(x: 0, y: 10))
        path.addQuadCurve(to: CGPoint(x: 10, y: 0), control: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 24, y: 0))
        
        // Top Right Corner
        path.move(to: CGPoint(x: rect.size.width - 24, y: 0))
        path.addLine(to: CGPoint(x: rect.size.width - 10, y: 0))
        path.addQuadCurve(to: CGPoint(x: rect.size.width, y: 10), control: CGPoint(x: rect.size.width, y: 0))
        path.addLine(to: CGPoint(x: rect.size.width, y: 24))
        
        // Bottom Right Corner
        path.move(to: CGPoint(x: rect.size.width, y: rect.size.height - 24))
        path.addLine(to: CGPoint(x: rect.size.width, y: rect.size.height - 10))
        path.addQuadCurve(to: CGPoint(x: rect.size.width - 10, y: rect.size.height), control: CGPoint(x: rect.size.width, y: rect.size.height))
        path.addLine(to: CGPoint(x: rect.size.width - 24, y: rect.size.height))
        
        // Bottom Left Corner
        path.move(to: CGPoint(x: 24, y: rect.size.height))
        path.addLine(to: CGPoint(x: 10, y: rect.size.height))
        path.addQuadCurve(to: CGPoint(x: 0, y: rect.size.height - 10), control: CGPoint(x: 0, y: rect.size.height))
        path.addLine(to: CGPoint(x: 0, y: rect.size.height - 24))
        
        return path
    }
}
