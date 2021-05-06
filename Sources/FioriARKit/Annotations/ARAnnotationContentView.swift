// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  ARAnnotationContentView.swift
//
//
//  Created by O'Brien, Patrick on 1/20/21.
//

import SwiftUI

public struct ARAnnotationContentView<Scan: View, Card: View, Marker: View, CardItem>: View where CardItem : CardItemModel {
    
    @ObservedObject public var arModel: ARAnnotationViewModel<CardItem>
    
    public let image: Image
    public let scanLabel: (Image, Binding<CGPoint?>) -> Scan
    public let cardLabel: (CardItem, Bool) -> Card
    public let markerLabel: (MarkerControl.State, Image?) -> Marker
    
    @State private var currentIndex: Int = 0
    @State private var displayLine = false
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder scanLabel: @escaping (Image, Binding<CGPoint?>) -> Scan,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker) {
        
        self.arModel = arModel
        self.image = image
        self.scanLabel = scanLabel
        self.cardLabel = cardLabel
        self.markerLabel = markerLabel
        self._currentIndex = State(initialValue: 0)
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ARContainer(arState: arModel)
            
            if arModel.discoveryFlowHasFinished {
                ForEach(0..<arModel.annotations.count) { index in
                    
                    if let focusedAnnotation = arModel.currentAnnotation {
                        
                        if focusedAnnotation.id == arModel.annotations[index].id && displayLine && focusedAnnotation.isMarkerVisible {
                            LineView(displayLine: $displayLine,
                                     startPoint: CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.maxY - 200),
                                     endPoint: arModel.annotations[index].screenPosition)
                        }
                        
                        MarkerContainer(state: focusedAnnotation.id == arModel.annotations[index].id ? .selected: .normal,
                                        icon: arModel.annotations[index].icon,
                                        screenPosition: arModel.annotations[index].screenPosition,
                                        isMarkerVisible: arModel.annotations[index].isMarkerVisible,
                                        label: markerLabel)
                            .onTapGesture {
                                currentIndex = index
                            }
                    }
                }
                
                CarouselScrollView(arModel.annotations, currentIndex: $currentIndex) { annotation in
                    
                    if let focusedAnnotation = arModel.currentAnnotation {
                        
                        CardContainer(cardItemModel: annotation.card,
                                      isSelected: focusedAnnotation.id == annotation.id,
                                      isCardVisible: annotation.isCardVisible,
                                      label: cardLabel)
                            .onTapGesture {
                                currentIndex = arModel.annotations.firstIndex(of: annotation) ?? 0
                            }
                    }
                    
                }
                .padding(.bottom, 50)
                .onChange(of: currentIndex, perform: { index in
                    arModel.currentAnnotation = arModel.annotations[index]
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        displayLine = true
                    }
                })
                .transition(.move(edge: .bottom))
                .animation(Animation.interpolatingSpring(mass: 1, stiffness: 800, damping: 60), value: currentIndex)
                
            } else {
                scanLabel(image, $arModel.anchorPosition)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .overlay(DismissButton(onDismiss: onDismiss).opacity(Double(0.8)), alignment: .topLeading)
        
    }
    
    private func onDismiss() {
        arModel.cleanUpSession()
    }
    
    private struct DismissButton: View {
        let onDismiss: (() -> Void)?
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
        var body: some View {
            Button(action: {
                onDismiss?()
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Image(systemName: "arrow.backward")
                    .frame(width: 44, height: 44)
                    .font(.system(size: 19))
                    .foregroundColor(Color(red: 250/255, green: 250/255, blue: 250/255))
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.black.opacity(0.6))
                    )
            })
            .padding(.leading, 16)
        }
    }
}

extension ARAnnotationContentView where Scan == ARScanView,
                                        Card == CardView<Text, _ConditionalContent<Text, EmptyView>, _ConditionalContent<ImagePreview, DefaultIcon>, _ConditionalContent<Text, EmptyView>, CardItem>,
                                        Marker == MarkerView {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: { image, anchorPosition in ARScanView(image: image, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

extension ARAnnotationContentView where Scan == ARScanView,
                                        Card == CardView<Text, _ConditionalContent<Text, EmptyView>, _ConditionalContent<ImagePreview, DefaultIcon>, _ConditionalContent<Text, EmptyView>, CardItem> {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker,
                cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: { image, anchorPosition in ARScanView(image: image, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: markerLabel)
    }
}

extension ARAnnotationContentView where Scan == ARScanView,
                                        Marker == MarkerView {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: { image, anchorPosition in ARScanView(image: image, anchorPosition: anchorPosition) },
                  cardLabel: cardLabel,
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

extension ARAnnotationContentView where Card == CardView<Text, _ConditionalContent<Text, EmptyView>, _ConditionalContent<ImagePreview, DefaultIcon>, _ConditionalContent<Text, EmptyView>, CardItem>,
                                        Marker == MarkerView {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder scanLabel: @escaping (Image, Binding<CGPoint?>) -> Scan,
                cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: scanLabel,
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

extension ARAnnotationContentView where Scan == ARScanView {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: { image, anchorPosition in ARScanView(image: image, anchorPosition: anchorPosition) },
                  cardLabel: cardLabel,
                  markerLabel: markerLabel)
    }
}

extension ARAnnotationContentView where Marker == MarkerView {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder scanLabel: @escaping (Image, Binding<CGPoint?>) -> Scan,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: scanLabel,
                  cardLabel: cardLabel,
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

extension ARAnnotationContentView where Card == CardView<Text, _ConditionalContent<Text, EmptyView>, _ConditionalContent<ImagePreview, DefaultIcon>, _ConditionalContent<Text, EmptyView>, CardItem> {
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                image: Image,
                @ViewBuilder scanLabel: @escaping (Image, Binding<CGPoint?>) -> Scan,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker,
                cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  image: image,
                  scanLabel: scanLabel,
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: markerLabel)
    }
}


