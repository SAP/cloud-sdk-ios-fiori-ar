// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  SwiftUIView.swift
//  
//
//  Created by O'Brien, Patrick on 4/17/21.
//

import SwiftUI

public struct MarkerView: View {
    var state: MarkerControl.State
    var icon: Image
    
    @State private var selectedScale: CGFloat = 0.57
    @State private var unselectedScale: CGFloat = 1.75
    @State private var pulseScale: CGFloat = 0.5
    @State private var pulseOpacity: Double = 0.15
    
    public init(state: MarkerControl.State, icon: Image?) {
        self.state = state
        self.icon = icon ?? Image(systemName: "info")
    }
    
    var unselected: some View {
        
        icon
            .font(.system(size: 16))
            .foregroundColor(Color(red: 10/255, green: 110/255, blue: 209/255))
            .background(
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.15))
                            .frame(width: 40, height: 40)
                    )
            )
            .frame(width: 44, height: 44)
            .contentShape(Rectangle())
            .scaleEffect(unselectedScale)
            .animateOnAppear(animation: .interpolatingSpring(mass: 1, stiffness: 800, damping: 60)) {
                // Reset selected states
                selectedScale = 0.57
                pulseScale = 0.5
                pulseOpacity = 0.15
                // animate unselected
                unselectedScale = 1
            }
    }
    
    var selected: some View {
        
        icon
            .font(.system(size: 28))
            .foregroundColor(.white)
            .background(
                Circle()
                    .strokeBorder(Color.white, lineWidth: 1)
                    .background(
                        Circle()
                            .foregroundColor(Color(red: 10/255, green: 110/255, blue: 209/255))
                    )
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(Color.black.opacity(0.15))
                            .frame(width: 70, height: 70)
                            .background(
                                Circle()
                                    .fill(Color.white.opacity(pulseOpacity))
                                    .frame(width: 70, height: 70)
                                    .scaleEffect(pulseScale)
                                    .animateOnAppear(animation: Animation.linear(duration: 0.7)) {
                                        // animate pulse
                                        pulseScale = 2.75
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                            withAnimation(Animation.linear(duration: 0.3)) {
                                                pulseOpacity = 0
                                            }
                                        }
                                    }
                            )
                    )
            )
            .scaleEffect(selectedScale)
            .animateOnAppear(animation: Animation.interpolatingSpring(mass: 3, stiffness: 1000, damping: 60).delay(0.072)) {
                // reset unselected state
                unselectedScale = 1.75
                // animated selected
                selectedScale = 1.1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.interpolatingSpring(mass: 3, stiffness: 1000, damping: 60)) {
                        selectedScale = 1
                    }
                }
            }
    }
    
    public var body: some View {
        if state == .selected {
            selected
        } else {
            unselected
        }
    }
}
