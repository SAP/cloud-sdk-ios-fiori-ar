//
//  ARAnnotationsView.swift
//
//
//  Created by O'Brien, Patrick on 5/11/21.
//

import FioriThemeManager
import SwiftUI

/**
 Content View which displays the card and marker views after a discovery flow for a single Image in the scene after the discoveryFlowHasFinished has been set to True. Only displays the views which are set to isVisible. Cards and Markers are initially set to isVisible.
 
  - Parameters:
    - arModel: The ViewModel which managers the AR Experience
    - image: The image that is provided to the ScanView which displays what should be discovered for in the physical scene for the User
    - scanLabel: View Builder for a custom Scanning View. After the Image/Object has been discovered there is a 3 second delay until the ContentView displays Markers and Cards
    - cardLabel: View Builder for a custom CardView
    - markerLabel: View Builder for a custom MarkerView
 
 ## Usage
 ```
 // Constructor for Default ScanningView, CardView, and MarkerView
 ARAnnotationsView(arModel: arModel,
                       image: Image("qrImage"),
                       cardAction: { id in
                             // set the card action for id corresponding to the CardItemModel
                             print(id)
                       })
         .onAppear(perform: loadData)
 
 // Constructors with viewbuilders for each combination of Views
 // Use the CarouselOptions View Modifier to adjust the behavior of the Carousel
 ARAnnotationsView(arModel: arModel,
                       scanLabel: { anchorPosition in
                           CustomScanView(image: Image("qrImage"), position: anchorPosition)
                       },
                       cardLabel: { cardmodel, isSelected in
                           CustomCardView(networkModel: cardmodel, isSelected: isSelected)
                       },
                       markerLabel: { state, icon  in
                           CustomMarkerView(state: state)
                       })
         .carouselOptions(CarouselOptions(itemSpacing: 5, carouselHeight: 200, alignment: .center))
         .onAppear(perform: loadData)
 
 func loadData() {
     let cardItems = Tests.cardItems
     guard let anchorImage = UIImage(named: "qrImage") else { return }
     let strategy = RealityComposerStrategy(cardContents: cardItems, anchorImage: anchorImage, rcFile: "ExampleRC", rcScene: "ExampleScene")
     arModel.load(loadingStrategy: strategy)
 }
 ```
 */

public struct ARAnnotationsView<Scan: View, Card: View, Marker: View, CardItem>: View where CardItem: CardItemModel {
    /// arModel
    @ObservedObject public var arModel: ARAnnotationViewModel<CardItem>
    
    /// View Builder for a custom Scanning View. After the Image/Object has been discovered there is a 3 second delay until the ContentView displays Markers and Cards
    public let scanLabel: (Binding<UIImage?>, Binding<CGPoint?>) -> Scan
    
    /// View Builder for a custom CardView
    public let cardLabel: (CardItem, Bool) -> Card
    
    /// ViewBuilder for a custom MarkerView
    public let markerLabel: (MarkerControl.State, Image?) -> Marker
    
    let guideImage: UIImage?
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                guideImage: UIImage? = nil,
                @ViewBuilder scanLabel: @escaping (Binding<UIImage?>, Binding<CGPoint?>) -> Scan,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker)
    {
        self.arModel = arModel
        self.guideImage = guideImage
        self.scanLabel = scanLabel
        self.cardLabel = cardLabel
        self.markerLabel = markerLabel
    }
    
    public var body: some View {
        ZStack {
            ARContainer(arStorage: arModel.arManager)
            
            if arModel.discoveryFlowHasFinished {
                ARAnnotationContentView(arModel, cardLabel: cardLabel, markerLabel: markerLabel)
            } else {
                scanLabel(guideImage == nil ? $arModel.guideImage : .constant(guideImage), $arModel.anchorPosition)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .overlay(DismissButton(onDismiss: onDismiss).opacity(Double(0.8)), alignment: .topLeading)
    }
    
    private func onDismiss() {
        self.arModel.resetAllAnchors()
    }
    
    private struct DismissButton: View {
        let onDismiss: (() -> Void)?
        @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
        
        var body: some View {
            Button(action: {
                onDismiss?()
                self.presentationMode.wrappedValue.dismiss()
            }, label: {
                Text(Image(systemName: "xmark"))
                    .fontWeight(.light)
                    .font(.system(size: 19))
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color.preferredColor(.primaryLabel, background: .darkConstant))
                    .background(
                        RoundedRectangle(cornerRadius: 13)
                            .fill(Color.black.opacity(0.6))
                    )
            })
                .padding([.leading, .top], 16)
        }
    }
}

public extension ARAnnotationsView where Scan == ARScanView,
    Card == CardView<Text,
        _ConditionalContent<Text, EmptyView>,
        _ConditionalContent<ImagePreview, DefaultIcon>,
        _ConditionalContent<Text, EmptyView>, CardItem>,
    Marker == MarkerView
{
    init(arModel: ARAnnotationViewModel<CardItem>,
         guideImage: UIImage? = nil,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  guideImage: guideImage,
                  scanLabel: { guideImage, anchorPosition in ARScanView(guideImage: guideImage, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

public extension ARAnnotationsView where Scan == ARScanView,
    Card == CardView<Text,
        _ConditionalContent<Text, EmptyView>,
        _ConditionalContent<ImagePreview, DefaultIcon>,
        _ConditionalContent<Text, EmptyView>, CardItem>
{
    init(arModel: ARAnnotationViewModel<CardItem>,
         guideImage: UIImage? = nil,
         @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  guideImage: guideImage,
                  scanLabel: { guideImage, anchorPosition in ARScanView(guideImage: guideImage, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: markerLabel)
    }
}

public extension ARAnnotationsView where Scan == ARScanView,
    Marker == MarkerView
{
    init(arModel: ARAnnotationViewModel<CardItem>,
         guideImage: UIImage? = nil,
         @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card)
    {
        self.init(arModel: arModel,
                  guideImage: guideImage,
                  scanLabel: { guideImage, anchorPosition in ARScanView(guideImage: guideImage, anchorPosition: anchorPosition) },
                  cardLabel: cardLabel,
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

public extension ARAnnotationsView where Card == CardView<Text,
    _ConditionalContent<Text, EmptyView>,
    _ConditionalContent<ImagePreview, DefaultIcon>,
    _ConditionalContent<Text, EmptyView>,
    CardItem>,
    Marker == MarkerView
{
    init(arModel: ARAnnotationViewModel<CardItem>,
         guideImage: UIImage? = nil,
         @ViewBuilder scanLabel: @escaping (Binding<UIImage?>, Binding<CGPoint?>) -> Scan,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  guideImage: guideImage,
                  scanLabel: scanLabel,
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

public extension ARAnnotationsView where Scan == ARScanView {
    init(arModel: ARAnnotationViewModel<CardItem>,
         guideImage: UIImage? = nil,
         @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
         @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker)
    {
        self.init(arModel: arModel,
                  guideImage: guideImage,
                  scanLabel: { guideImage, anchorPosition in ARScanView(guideImage: guideImage, anchorPosition: anchorPosition) },
                  cardLabel: cardLabel,
                  markerLabel: markerLabel)
    }
}

public extension ARAnnotationsView where Marker == MarkerView {
    init(arModel: ARAnnotationViewModel<CardItem>,
         @ViewBuilder scanLabel: @escaping (Binding<UIImage?>, Binding<CGPoint?>) -> Scan,
         @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card)
    {
        self.init(arModel: arModel,
                  scanLabel: scanLabel,
                  cardLabel: cardLabel,
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}

public extension ARAnnotationsView where Card == CardView<Text,
    _ConditionalContent<Text, EmptyView>,
    _ConditionalContent<ImagePreview, DefaultIcon>,
    _ConditionalContent<Text, EmptyView>,
    CardItem>
{
    init(arModel: ARAnnotationViewModel<CardItem>,
         @ViewBuilder scanLabel: @escaping (Binding<UIImage?>, Binding<CGPoint?>) -> Scan,
         @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  scanLabel: scanLabel,
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: markerLabel)
    }
}
