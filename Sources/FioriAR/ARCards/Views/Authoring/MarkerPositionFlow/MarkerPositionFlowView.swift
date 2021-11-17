//
//  MarkerPositionFlowView.swift
//
//
//  Created by O'Brien, Patrick on 5/11/21.
//

import FioriThemeManager
import SwiftUI

enum MarkerFlowState {
    case arscene
    case editMarker
    case selectMarker
    case selectCard
    case confirmCard
    case beforeDrop
    case dropped
    case preview
}

struct MarkerPositioningFlowView<Scan: View, Card: View, Marker: View, CardItem>: View where CardItem: CardItemModel, CardItem.ID: StringProtocol {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var arModel: ARAnnotationViewModel<CardItem>
    
    @Binding var cardItems: [CardItem]
    @Binding var attachmentsMetadata: [AttachmentUIMetadata]
    
    @State private var cardItem: CardItem? = nil
    @State private var flowState: MarkerFlowState = .arscene
    @State private var sheetState: PartialSheetState = .notVisible
    @State private var sheetTitle = "Add Annotation"
    @State private var firstPage = true
    @State private var displayPagingView = true
    @State private var carouselVisible = true
    
    let onDismiss: (() -> Void)?
    let scanLabel: (CGPoint?) -> Scan
    let cardLabel: (CardItem, Bool) -> Card
    let markerLabel: (MarkerControl.State, Image?) -> Marker
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                cardItems: Binding<[CardItem]>,
                attachmentsMetadata: Binding<[AttachmentUIMetadata]>,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder scanLabel: @escaping (CGPoint?) -> Scan,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker)
    {
        self.arModel = arModel
        _cardItems = cardItems
        _attachmentsMetadata = attachmentsMetadata
        self.onDismiss = onDismiss
        self.scanLabel = scanLabel
        self.cardLabel = cardLabel
        self.markerLabel = markerLabel
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ARContainer(arStorage: arModel.arManager)
            
            if arModel.discoveryFlowHasFinished {
                ARAnnotationContentView(arModel,
                                        carouselIsVisible: $carouselVisible,
                                        cardLabel: cardLabel,
                                        markerLabel: markerLabel) { cardItem in
                    guard flowState == .editMarker || flowState == .selectMarker else { return }
                    self.cardItem = cardItem
                    flowState = .selectMarker
                    arModel.onlyShowEntity(for: cardItem)
                    sheetState = .closed
                }
                .zIndex(2)
                
                FlowButtonsView(flowState: $flowState, cardItem: cardItem, onPublish: {
                    if let cardItem = cardItem {
                        arModel.reAddEntitiesToScene(exclude: [cardItem])
                    }
                })
                
                PartialSheetView($sheetState,
                                 title: sheetTitle,
                                 onLeftAction: flowState == .confirmCard ? onPageBack : nil,
                                 onRightAction: { flowState = .editMarker }) {
                    if displayPagingView {
                        PagingView(firstPage: $firstPage, left: {
                            AttachmentsView(attachmentsUIMetadata: attachmentsMetadata.filter { $0.subtitle == AttachValue.notAttached.rawValue },
                                            onSelectAttachment: { attachment in
                                                cardItem = cardItems.first(where: { attachment.id.uuidString == $0.id })
                                                firstPage = false
                                                flowState = .confirmCard
                                            })
                        }, right: {
                            CardSelectionView(cardItem: cardItem, onSelect: {
                                flowState = .beforeDrop
                            })
                        })
                    } else {
                        CardPreview(cardItem: cardItem)
                    }
                }
            } else {
                scanLabel(arModel.anchorPosition)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .overlay(BackButton(flowState: flowState, onAction: dismiss), alignment: .topLeading)
        .overlay(
            Group {
                if arModel.discoveryFlowHasFinished {
                    EditButton(flowState: flowState, onAction: onEdit)
                }
            }, alignment: .topTrailing
        )
        .onTapGesture {
            if flowState == .editMarker || flowState == .selectMarker {
                arModel.setAllMarkerState(to: .ghost)
                sheetState = .notVisible
                flowState = .editMarker
            }
        }
        .onChange(of: flowState) { newValue in
            switch newValue {
            case .arscene:
                arModel.setSelectedAnnotation(for: arModel.annotations.first)
                sheetState = .notVisible
                withAnimation { carouselVisible = true }
            case .editMarker:
                sheetTitle = "View Annotation"
                arModel.setAllMarkerState(to: .ghost)
                sheetState = .notVisible
                withAnimation { carouselVisible = false }
            case .selectMarker:
                displayPagingView = false
                sheetState = .closed
            case .selectCard:
                sheetTitle = "Add Annotation"
                displayPagingView = true
                arModel.setAllMarkerState(to: .notVisible)
                sheetState = .open
            case .confirmCard:
                sheetTitle = "Preview Annotation"
                sheetState = .open
            case .beforeDrop:
                arModel.removeEntitiesFromScene()
                setPinValue(cardItem: cardItem, pinValue: .attached)
                arModel.addNewEntity(to: cardItem)
                arModel.setMarkerState(for: cardItem, to: .world)
                sheetTitle = "View Annotation"
                sheetState = .closed
            case .dropped:
                arModel.dropEntity(for: cardItem)
                sheetState = .closed
                firstPage = true
            case .preview:
                sheetState = .notVisible
                arModel.setMarkerState(for: cardItem, to: .selected)
            }
        }
    }
    
    func onPageBack() {
        self.firstPage = true
        self.flowState = .selectCard
    }
    
    func dismiss() {
        switch self.flowState {
        case .preview:
            self.flowState = .dropped
        default:
            self.arModel.updateCardItemPositions()
            self.cardItems = self.arModel.annotations.map(\.card)
            self.arModel.resetAllAnchors()
            self.onDismiss?()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onEdit() {
        switch self.flowState {
        case .arscene:
            self.flowState = .editMarker
        case .editMarker, .beforeDrop:
            self.flowState = .selectCard
        case .selectMarker:
            self.setPinValue(cardItem: self.cardItem, pinValue: .notAttached)
            self.arModel.deleteEntity(for: self.cardItem)
            self.cardItem = nil
            self.flowState = .editMarker
        case .dropped:
            self.setPinValue(cardItem: self.cardItem, pinValue: .notAttached)
            self.arModel.deleteEntity(for: self.cardItem)
            self.arModel.deleteCameraAnchor()
            self.flowState = .selectCard
        case .selectCard, .confirmCard, .preview:
            break
        }
    }
    
    func setPinValue(cardItem: CardItem?, pinValue: AttachValue) {
        guard let cardItem = cardItem,
              let index = attachmentsMetadata.firstIndex(where: { $0.id.uuidString == cardItem.id }) else { return }
        self.attachmentsMetadata[index].subtitle = pinValue.rawValue
    }
}

private struct BackButton: View {
    var flowState: MarkerFlowState
    var onAction: (() -> Void)?
    
    var isActive: Bool {
        switch self.flowState {
        case .selectCard, .confirmCard:
            return false
        default:
            return true
        }
    }
    
    var body: some View {
        if isActive {
            Button(action: {
                onAction?()
            }, label: {
                Image(systemName: flowState == .preview ? "chevron.left" : "xmark")
                    .font(.system(size: 19))
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color.fioriNextPrimaryBackground)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.fioriNextPrimaryLabel.opacity(0.25))
                    )
            })
                .padding([.leading, .top], 16)
        }
    }
}

private struct EditButton: View {
    var flowState: MarkerFlowState
    var onAction: (() -> Void)?
    
    var isActive: Bool {
        switch self.flowState {
        case .selectCard, .confirmCard, .preview:
            return false
        default:
            return true
        }
    }
    
    var body: some View {
        if isActive {
            Button(action: {
                onAction?()
            }, label: {
                Image(systemName: icon())
                    .font(.system(size: 19))
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color.fioriNextPrimaryBackground)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.fioriNextPrimaryLabel.opacity(0.25))
                    )
            })
                .padding([.top, .trailing], 16)
        }
    }
    
    func icon() -> String {
        switch self.flowState {
        case .arscene:
            return "pencil"
        case .editMarker:
            return "plus"
        case .selectMarker, .beforeDrop, .dropped:
            return "trash"
        default:
            return "info"
        }
    }
}

extension MarkerPositioningFlowView where Scan == ARScanView,
    Card == CardView<Text,
        _ConditionalContent<Text, EmptyView>,
        _ConditionalContent<ImagePreview, DefaultIcon>,
        _ConditionalContent<Text, EmptyView>, CardItem>,
    Marker == MarkerView
{
    init(arModel: ARAnnotationViewModel<CardItem>,
         cardItems: Binding<[CardItem]>,
         attachmentsMetadata: Binding<[AttachmentUIMetadata]>,
         onDismiss: (() -> Void)?,
         image: UIImage?,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  cardItems: cardItems,
                  attachmentsMetadata: attachmentsMetadata,
                  onDismiss: onDismiss,
                  scanLabel: { anchorPosition in ARScanView(guideImage: image, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}
