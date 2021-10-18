//
//  PartialSheetView.swift
//
//
//  Created by O'Brien, Patrick on 10/5/21.
//

import RealityKit
import SwiftUI

enum PartialSheetState: CGFloat {
    case open = 0
    case almostOpen = 76
    case closed = 319
    case notVisible = 395
}

struct PartialSheetView<Content>: View where Content: View {
    @Binding var title: String
    @Binding var sheetState: PartialSheetState
    
    let onDismiss: (() -> Void)?
    let content: () -> Content
    
    init(title: Binding<String>, sheetState: Binding<PartialSheetState>, onDismiss: (() -> Void)? = nil, @ViewBuilder content: @escaping () -> Content) {
        _title = title
        _sheetState = sheetState
        self.onDismiss = onDismiss
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack {
                handle
                HStack {
                    Text(title)
                        .foregroundColor(Color.black)
                        .font(.system(size: 17, weight: .bold))
                    
                    Spacer()
                    
                    dismissView
                        .opacity(sheetState != .closed ? 1 : 0)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)
            
            content()
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: 395)
        .background(
            RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                .fill(Color.fioriNextPrimaryBackground)
        )
        .offset(y: sheetState.rawValue)
        .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0), value: sheetState)
    }
    
    private var dismissView: some View {
        Button(action: {
            sheetState = .closed
            onDismiss?()
        }, label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold, design: .default))
                .foregroundColor(Color.fioriNextTertiaryLabel.opacity(0.9))
                .background(
                    Circle()
                        .fill(Color.fioriNextSecondaryFill.opacity(0.16))
                        .frame(width: 28, height: 28)
                )
        })
    }
    
    private var handle: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color(red: 137 / 255, green: 145 / 255, blue: 154 / 255, opacity: 0.41))
            .frame(width: 36, height: 5)
            .padding(.vertical, 6)
    }
    
    private var dragGesture: _EndedGesture<DragGesture> {
        DragGesture(minimumDistance: 20)
            .onEnded { value in
                let horizontalAmount = value.translation.width
                let verticalAmount = value.translation.height
                
                if abs(verticalAmount) > abs(horizontalAmount) {
                    let direction: SwipeDirection = verticalAmount < 0 ? .up : .down
                    
                    switch sheetState {
                    case .open:
                        switch direction {
                        case .up:
                            break
                        case .down:
                            sheetState = .almostOpen
                        }
                    case .almostOpen:
                        switch direction {
                        case .up:
                            sheetState = .open
                        case .down:
                            sheetState = .closed
                        }
                    case .closed:
                        switch direction {
                        case .up:
                            sheetState = .almostOpen
                        case .down:
                            break
                        }
                    case .notVisible:
                        break
                    }
                }
            }
    }
    
    private enum SwipeDirection {
        case up
        case down
    }
}
