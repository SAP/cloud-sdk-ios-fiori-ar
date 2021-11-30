//
//  ARCardsViewBuilderContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriAR
import SwiftUI

struct ARCardsViewBuilderContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<StringIdentifyingCardItem>()
    
    var body: some View {
        ARAnnotationsView(arModel: arModel,
                          scanLabel: { guideImageState, anchorPosition in
                              CustomScanView(guideImageState: guideImageState, position: anchorPosition)
                          },
                          cardLabel: { cardmodel, isSelected in
                              CustomCardView(model: cardmodel, isSelected: isSelected)
                          },
                          markerLabel: { state, _ in
                              CustomMarkerView(state: state)
                          })
            .carouselOptions(CarouselOptions(itemSpacing: 5, carouselHeight: 200, alignment: .center))
            .onAppear(perform: loadInitialData)
    }
    
    func loadInitialData() {
        let cardItems = Tests.carEngineCardItems
        guard let anchorImage = UIImage(named: "qrImage") else { return }
        let strategy = RCProjectStrategy(cardContents: cardItems, anchorImage: anchorImage, physicalWidth: 0.1, rcFile: "ExampleRC", rcScene: "ExampleScene")
        do {
            try self.arModel.load(loadingStrategy: strategy)
        } catch {
            print(error)
        }
    }
}

struct CustomScanView: View {
    var guideImageState: GuideImageState
    var position: CGPoint?
    
    var body: some View {
        ZStack {
            if let position = position {
                Text("Discovered!")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.green.opacity(0.7))
                            .frame(width: 150, height: 150)
                    )
                    .position(position)
            }
            VStack(spacing: 15) {
                Spacer()
                if case .finished(let guideImage) = guideImageState {
                    Image(uiImage: guideImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150)
                }
                
                Text("Discover this Image!")
                    .font(.system(size: 19))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
                    .padding(.bottom, 50)
            }
        }
    }
}

struct CustomCardView<CardItem: CardItemModel>: View {
    var model: CardItem
    var isSelected: Bool
    @State var color: Color = .gray
    
    var body: some View {
        VStack(spacing: 10) {
            Button("Change Color") {
                let background: [Color] = [.red, .yellow, .blue]
                color = background.randomElement()!
            }
            .foregroundColor(.white)
            .font(.system(size: 24))
            
            Text(model.title_)
            Button(model.actionText_ ?? "") {}
        }
        .foregroundColor(isSelected ? Color.white : Color.black)
        .frame(width: 250, height: isSelected ? 200 : 150)
        .background(color)
        .cornerRadius(10)
    }
}

struct CustomMarkerView: View {
    var state: MarkerControl.State
    @State var rotation: Double = 0
    
    var body: some View {
        Text("Tap Me")
            .font(.system(size: 12))
            .foregroundColor(state == .selected ? Color.white : Color.black)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(state == .selected ? Color.blue : Color.white)
                    .frame(width: 100, height: 100)
            )
            .rotationEffect(.degrees(rotation))
            .onChange(of: state == .selected, perform: { value in
                withAnimation {
                    rotation = value ? 180 : 0
                }
            })
    }
}
