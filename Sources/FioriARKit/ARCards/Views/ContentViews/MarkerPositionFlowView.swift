//
//  MarkerPositionFlowView.swift
//
//
//  Created by O'Brien, Patrick on 5/11/21.
//

import CoreML
import FioriThemeManager
import SwiftUI

enum MarkerFlowState {
    case arscene
    case editMarker
    case selectCard
    case confirmCard
    case beforeDrop
    case dropped
    case preview
}

struct MarkerPositioningFlowView<Scan: View, Card: View, Marker: View, CardItem>: View where CardItem: CardItemModel, CardItem.ID: StringProtocol {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var onDismiss: (() -> Void)?
    
    @ObservedObject public var arModel: ARAnnotationViewModel<CardItem>
    @Binding var cardItems: [CardItem]
    @Binding var attachments: [AttachmentUIMetadata]
    
    @State var attachmentsMetadata: [AttachmentUIMetadata] = []
    @State var cardItem: CardItem? = nil
    
    @State private var firstPage = true
    @State private var sheetState: PartialSheetState = .notVisible
    @State private var flowState: MarkerFlowState = .arscene
    
    @State private var carouselVisible = true
    @State private var markersVisible = true
    
    let scanLabel: (Binding<CGPoint?>) -> Scan
    let cardLabel: (CardItem, Bool) -> Card
    let markerLabel: (MarkerControl.State, Image?) -> Marker
    
    public init(arModel: ARAnnotationViewModel<CardItem>,
                cardItems: Binding<[CardItem]>,
                attachments: Binding<[AttachmentUIMetadata]>,
                onDismiss: (() -> Void)? = nil,
                @ViewBuilder scanLabel: @escaping (Binding<CGPoint?>) -> Scan,
                @ViewBuilder cardLabel: @escaping (CardItem, Bool) -> Card,
                @ViewBuilder markerLabel: @escaping (MarkerControl.State, Image?) -> Marker)
    {
        self.arModel = arModel
        self._cardItems = cardItems
        self._attachments = attachments
        self.onDismiss = onDismiss
        self.scanLabel = scanLabel
        self.cardLabel = cardLabel
        self.markerLabel = markerLabel
    }
    
    public var body: some View {
        ZStack(alignment: .bottom) {
            ARContainer(arStorage: arModel.arManager)
            
            if arModel.discoveryFlowHasFinished {
                ARAnnotationContentView($arModel.annotations,
                                        currentAnnotation: $arModel.currentAnnotation,
                                        cardLabel: cardLabel,
                                        markerLabel: markerLabel,
                                        carouselIsVisible: $carouselVisible,
                                        markersVisible: $markersVisible) { id in
                    guard flowState == .editMarker else { return }
                    if let index = arModel.annotations.firstIndex(where: { $0.id == id }) {
                        arModel.annotations[index].showInternalEntity()
                        arModel.annotations[index].setMarkerVisibility(to: false)
                    }
                }
                
                if flowState == .beforeDrop {
                    Button(action: {
                        arModel.addNewEntity(for: cardItem)
                        flowState = .dropped
                        firstPage = true
                    }, label: {
                        Text("Drop Marker")
                            .font(.system(size: 15, weight: .bold))
                            .frame(width: 343, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.fioriNextTint)
                            )
                    })
                        .padding(.bottom, 100)
                }
                
                if flowState == .dropped {
                    HStack(spacing: 8) {
                        Button(action: { flowState = .selectCard }, label: {
                            Text("Add Another")
                                .font(.system(size: 15, weight: .bold))
                                .frame(width: 122, height: 40)
                                .foregroundColor(.black)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white)
                                )
                        })
                        
                        Button(action: { flowState = .preview }, label: {
                            Text("Go To Preview")
                                .font(.system(size: 15, weight: .bold))
                                .frame(width: 213, height: 40)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.fioriNextTint)
                                )
                        })
                    }
                    .padding(.bottom, 100)
                }
                
                if flowState == .preview {
                    VStack(spacing: 20) {
                        CardPreview(cardItem: cardItem)
                        Button(action: {
                            flowState = .arscene
                        }, label: {
                            Text("Publish")
                                .font(.system(size: 15, weight: .bold))
                                .frame(width: 343, height: 40)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.fioriNextTint)
                                )
                        })
                    }
                    .padding(.bottom, 100)
                }
                
                PartialSheetView(title: .constant("Add Annotation"), sheetState: $sheetState) {
                    PagingView(firstPage: $firstPage, left: {
                        AttachmentsView(attachmentsUIMetadata: $attachmentsMetadata, onSelectAttachment: { attachment in
                            guard let card = cardItems.first(where: { attachment.id.uuidString == $0.id }) else { return }
                            cardItem = card
                            withAnimation { firstPage = false }
                            flowState = .confirmCard
                        })
                    }, right: {
                        CardSelectionView(cardItem: cardItem, onBack: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                                cardItem = nil
                            }
                            withAnimation { firstPage = true }
                            flowState = .selectCard
                        }, onSelect: {
                            flowState = .beforeDrop
                        })
                    })
                }
            } else {
                scanLabel($arModel.anchorPosition)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .overlay(BackButton(flowState: $flowState, onAction: dismiss), alignment: .topLeading)
        .overlay(EditButton(flowState: $flowState, onAction: onEdit), alignment: .topTrailing)
        .overlay(Text(String(reflecting: flowState)).font(.system(size: 24)).foregroundColor(.white), alignment: .bottomTrailing)
        .onTapGesture {
            if flowState == .editMarker {
                for (index, _) in arModel.annotations.enumerated() {
                    arModel.annotations[index].setMarkerVisibility(to: true)
                    arModel.annotations[index].hideInternalEntity()
                }
                flowState = .arscene
            }
        }
        .onChange(of: flowState) { newValue in
            switch newValue {
            case .arscene:
                for (index, _) in arModel.annotations.enumerated() {
                    arModel.annotations[index].setMarkerVisibility(to: true)
                }
                sheetState = .notVisible
                withAnimation { carouselVisible = true }
            case .editMarker:
                withAnimation { carouselVisible = false }
            case .selectCard:
                sheetState = .open
                for (index, _) in arModel.annotations.enumerated() {
                    arModel.annotations[index].isMarkerVisible = false
                    arModel.annotations[index].hideInternalEntity()
                }
            case .confirmCard:
                sheetState = .open
            case .beforeDrop:
                sheetState = .closed
            case .dropped:
                refreshAttachmentView()
            case .preview:
                sheetState = .notVisible
                arModel.setMarkerVisibility(for: cardItem, to: true)
            }
        }
        .onAppear(perform: populateAttachmentView)
    }
    
    func populateAttachmentView() {
        self.attachmentsMetadata.removeAll()
        self.cardItems
            .forEach { card in
                if card.position_ == nil {
                    var detailImage: Image?
                    if let data = card.detailImage_, let uiImage = UIImage(data: data) {
                        detailImage = Image(uiImage: uiImage)
                    }
                    
                    let newAttachmentModel = AttachmentUIMetadata(id: UUID(uuidString: String(card.id)) ?? UUID(),
                                                                  title: card.title_,
                                                                  subtitle: "Not Pinned Yet",
                                                                  info: nil,
                                                                  image: detailImage,
                                                                  icon: card.icon_ == nil ? nil : Image(card.icon_!))
                    attachmentsMetadata.append(newAttachmentModel)
                }
            }
    }
    
    func refreshAttachmentView() {
        self.arModel.updateCardItemPositions()
        self.cardItems = self.arModel.annotations.map(\.card)
        self.populateAttachmentView()
    }

    func dismiss() {
        switch self.flowState {
        case .preview:
            self.flowState = .dropped
            self.sheetState = .closed
        default:
            self.arModel.updateCardItemPositions()
            self.cardItems = self.arModel.annotations.map(\.card)
            self.onDismiss?()
            self.arModel.resetAllAnchors()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onEdit() {
        switch self.flowState {
        case .arscene:
            self.flowState = .editMarker
        case .editMarker:
            self.flowState = .selectCard
        case .beforeDrop:
            self.flowState = .selectCard
            self.refreshAttachmentView()
        case .dropped:
            self.refreshAttachmentView()
            self.arModel.removeEntity(for: self.cardItem)
        case .selectCard, .confirmCard, .preview:
            break
        }
    }
}

private struct BackButton: View {
    @Binding var flowState: MarkerFlowState
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
                Image(systemName: icon())
                    .font(.system(size: 19))
                    .frame(width: 44, height: 44)
                    .foregroundColor(Color.fioriNextPrimaryBackground)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.arbuttonTint.opacity(0.25))
                    )
            })
                .padding([.leading, .top], 16)
        }
    }
    
    func icon() -> String {
        switch self.flowState {
        case .preview:
            return "chevron.left"
        default:
            return "xmark"
        }
    }
}

private struct EditButton: View {
    @Binding var flowState: MarkerFlowState
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
                            .fill(Color.arbuttonTint.opacity(0.25))
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
        case .beforeDrop, .dropped:
            return "trash"
        default:
            return "info"
        }
    }
}

private struct CardSelectionView<CardItem: CardItemModel>: View {
    var cardItem: CardItem?
    var onBack: (() -> Void)?
    var onSelect: (() -> Void)?
    
    var body: some View {
        VStack {
            ZStack {
                Color.fioriNextPrimaryBackground
                CardPreview(cardItem: cardItem)
            }
            
            Spacer()
            
            HStack {
                Button(action: { onBack?() }, label: {
                    Text("Back")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 122, height: 40)
                        .foregroundColor(.black)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.white)
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 4, y: 2)
                        .shadow(color: Color.black.opacity(0.24), radius: 2)
                })
                
                Button(action: { onSelect?() }, label: {
                    Text("Select")
                        .font(.system(size: 15, weight: .bold))
                        .frame(width: 213, height: 40)
                        .foregroundColor(.white)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.fioriNextTint)
                        )
                        .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 4, y: 2)
                        .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 2)
                })
            }
            .padding(.bottom, 46)
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
         attachments: Binding<[AttachmentUIMetadata]>,
         onDismiss: (() -> Void)? = nil,
         image: Image,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  cardItems: cardItems,
                  attachments: attachments,
                  onDismiss: onDismiss,
                  scanLabel: { anchorPosition in ARScanView(image: image, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}
