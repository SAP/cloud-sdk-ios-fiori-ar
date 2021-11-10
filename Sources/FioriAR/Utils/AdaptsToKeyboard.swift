//
//  AdaptsToKeyboard.swift
//
//
//  Created by O'Brien, Patrick on 9/30/21.
//

import Combine
import SwiftUI

struct AdaptsToKeyboard: ViewModifier {
    @State var keyboardPadding: CGFloat = 0
    
    func body(content: Content) -> some View {
        GeometryReader { _ in
            content
                .padding(.bottom, keyboardPadding)
                .onReceive(Publishers.keyboardHeight) { keyboardHeight in
                    keyboardPadding = keyboardHeight
                }
                .animation(.easeInOut(duration: 0.30), value: keyboardPadding)
        }
    }
}

private extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willChange = NotificationCenter.default.publisher(for: UIApplication.keyboardWillChangeFrameNotification)
            .map(\.keyboardHeight)
        
        let willHide = NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)
            .map { _ in CGFloat.zero }
        
        return willChange.merge(with: willHide).eraseToAnyPublisher()
    }
}

private extension Notification {
    var keyboardHeight: CGFloat {
        (userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height ?? 0
    }
}
