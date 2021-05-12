//
//  ARAnnotationContentView.swift
//
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import SwiftUI

internal struct ARAnnotationContentView<Card: View,
                                        Marker: View,
                                        CardItem>: View where CardItem : CardItemModel {
    
    /// Screen Annotations
    @Binding internal var annotations: [ScreenAnnotation<CardItem>]
    
    /// Annotation that is focused in the center of screen with respective marker in selected state
    @Binding internal var currentAnnotation: ScreenAnnotation<CardItem>?
    
    /// View Builder for a custom CardView
    internal let cardLabel: (CardItem, Bool) -> Card
    
    /// ViewBuilder for custom MarkerView
    internal let markerLabel: (MarkerControl.State, Image?) -> Marker
    
    @State private var currentIndex: Int = 0
    @State private var displayLine = false
    
    internal init(_ annotations: Binding<[ScreenAnnotation<CardItem>]>,
                  currentAnnotation: Binding<ScreenAnnotation<CardItem>?>,
                  @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                  @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker) {
        
        self._annotations = annotations
        self._currentAnnotation = currentAnnotation
        self.cardLabel = cardLabel
        self.markerLabel = markerLabel
        self._currentIndex = State(initialValue: 0)
    }
    
    internal var body: some View {
        ZStack(alignment: .bottom) {
            
            ForEach(annotations) { annotation in
        
                if let focusedAnnotation = currentAnnotation {
                    
                    if focusedAnnotation.id == annotation.id && displayLine && focusedAnnotation.isMarkerVisible {
                        LineView(displayLine: $displayLine,
                                 startPoint: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 150),
                                 endPoint: annotation.screenPosition)
                    }
                    
                    MarkerContainer(state: focusedAnnotation.id == annotation.id ? .selected: .normal,
                                    icon: annotation.icon,
                                    screenPosition: annotation.screenPosition,
                                    isMarkerVisible: annotation.isMarkerVisible,
                                    label: markerLabel)
                        .onTapGesture {
                            currentIndex = annotations.firstIndex(of: annotation) ?? 0
                        }
                }
            }
            
            CarouselScrollView(annotations, currentIndex: $currentIndex) { annotation in
                
                if let focusedAnnotation = currentAnnotation {
                    
                    CardContainer(cardItemModel: annotation.card,
                                  isSelected: focusedAnnotation.id == annotation.id,
                                  isCardVisible: annotation.isCardVisible,
                                  label: cardLabel)
                        .onTapGesture {
                            currentIndex = annotations.firstIndex(of: annotation) ?? 0
                        }
                }
                
            }
            .padding(.bottom, 50)
            .onChange(of: currentIndex, perform: { index in
                currentAnnotation = annotations[index]
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    displayLine = true
                }
            })
            .transition(.move(edge: .bottom))
            .animation(Animation.interpolatingSpring(mass: 1, stiffness: 800, damping: 60), value: currentIndex)
        }
    }
}
