//
//  ARAnnotationContentView.swift
//
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import SwiftUI

internal struct ARAnnotationContentView<Card: View, Marker: View, CardItem>: View where CardItem: CardItemModel {
    @ObservedObject var arModel: ARAnnotationViewModel<CardItem>
    @Binding var carouselIsVisible: Bool

    let cardLabel: (CardItem, Bool) -> Card
    let markerLabel: (MarkerControl.State, Image?) -> Marker
    let onMarkerTap: ((CardItem) -> Void)?
    
    @State private var currentIndex: Int = 0
    @State private var displayLine = false
    
    private var visibleAnnotations: [ScreenAnnotation<CardItem>] {
        self.arModel.annotations.filter(\.isCardVisible)
    }
    
    internal init(_ arModel: ARAnnotationViewModel<CardItem>,
                  carouselIsVisible: Binding<Bool> = .constant(true),
                  @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                  @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker,
                  onMarkerTap: ((CardItem) -> Void)? = nil)
    {
        self.arModel = arModel
        self._carouselIsVisible = carouselIsVisible
        self.cardLabel = cardLabel
        self.markerLabel = markerLabel
        self.onMarkerTap = onMarkerTap
    }
    
    internal var body: some View {
        ZStack(alignment: .bottom) {
            ForEach(arModel.annotations) { annotation in
                if let focusedAnnotation = arModel.currentAnnotation, let position = annotation.screenPosition {
                    if focusedAnnotation.id == annotation.id, displayLine, focusedAnnotation.markerState != .notVisible {
                        LineView(displayLine: $displayLine,
                                 startPoint: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 150),
                                 endPoint: position)
                    }
                }
                    
                MarkerContainer(state: annotation.markerState,
                                icon: annotation.card.icon_,
                                screenPosition: annotation.screenPosition,
                                label: markerLabel)
                    .onTapGesture {
                        currentIndex = visibleAnnotations.firstIndex { $0.id == annotation.id } ?? 0
                        onMarkerTap?(annotation.card)
                    }
            }
            
            if carouselIsVisible {
                CarouselScrollView(visibleAnnotations, currentIndex: $currentIndex) { annotation in
                    CardContainer(cardItemModel: annotation.card,
                                  isSelected: annotation.markerState == .selected,
                                  label: cardLabel)
                        .onTapGesture {
                            currentIndex = visibleAnnotations.firstIndex { $0.id == annotation.id } ?? 0
                        }
                }
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom))
                .onChange(of: currentIndex) { newValue in
                    let annotation = visibleAnnotations[newValue]
                    arModel.setSelectedAnnotation(for: annotation)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        displayLine = true
                    }
                }
            }
        }
    }
}
