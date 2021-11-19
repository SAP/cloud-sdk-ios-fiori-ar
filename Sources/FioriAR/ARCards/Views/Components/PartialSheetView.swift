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
    @Binding var sheetState: PartialSheetState
    var title: String
    let onLeftAction: (() -> Void)?
    let onRightAction: (() -> Void)?
    let content: () -> Content
    
    init(_ sheetState: Binding<PartialSheetState>,
         title: String,
         onLeftAction: (() -> Void)? = nil,
         onRightAction: (() -> Void)? = nil,
         @ViewBuilder content: @escaping () -> Content)
    {
        _sheetState = sheetState
        self.title = title
        self.onLeftAction = onLeftAction
        self.onRightAction = onRightAction
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack {
                SheetHandle()
                HStack {
                    Text(title)
                        .font(.fiori(forTextStyle: .headline).weight(.bold))
                        .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                }
                .frame(maxWidth: .infinity)
                .overlay(leftActionButton, alignment: .leading)
                .overlay(rightActionButton, alignment: .trailing)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture)
            
            content()
        }
        .frame(maxWidth: .infinity, maxHeight: 395)
        .background(
            RoundedCorner(radius: 16, corners: [.topLeft, .topRight])
                .fill(Color.preferredColor(.primaryBackground, background: .lightConstant))
        )
        .offset(y: sheetState.rawValue)
        .animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0), value: sheetState)
    }
    
    @ViewBuilder
    var leftActionButton: some View {
        if let onLeftAction = onLeftAction {
            ActionView(icon: Image(systemName: "chevron.left")) {
                onLeftAction()
            }
            .opacity(sheetState != .closed ? 1 : 0)
        }
    }
    
    @ViewBuilder
    var rightActionButton: some View {
        if let onRightAction = onRightAction {
            ActionView(icon: Image(systemName: "xmark")) {
                onRightAction()
            }
            .opacity(sheetState != .closed ? 1 : 0)
        }
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

struct SheetHandle: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Color.preferredColor(.separator, background: .lightConstant))
            .frame(width: 36, height: 5)
            .padding(.vertical, 6)
    }
}

struct ActionView: View {
    let icon: Image
    let onAction: (() -> Void)?
    
    var body: some View {
        Button(action: {
            onAction?()
        }, label: {
            icon
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                .background(
                    Circle()
                        .fill(Color.preferredColor(.tertiaryFill, background: .lightConstant))
                        .frame(width: 28, height: 28)
                )
        })
    }
}
