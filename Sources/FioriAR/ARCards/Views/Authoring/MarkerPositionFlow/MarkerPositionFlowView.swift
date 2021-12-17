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
    case editMode
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
    @State private var sheetTitle = "Select Annotation"
    @State private var firstPage = true
    @State private var displayPagingView = false
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
                    guard flowState == .editMode || flowState == .selectMarker else { return }
                    self.cardItem = cardItem
                    flowState = .selectMarker
                    arModel.onlyShowEntity(for: cardItem)
                    sheetState = .closed
                }
                .zIndex(2)
                
                FlowButtonsView(flowState: $flowState, cardItem: cardItem)
                
                PartialSheetView($sheetState,
                                 title: sheetTitle,
                                 onLeftAction: flowState == .confirmCard ? onPageBack : nil,
                                 onRightAction: flowState == .selectCard || flowState == .confirmCard ? onDismissDrawer : nil) {
                    if displayPagingView {
                        PagingView(firstPage: $firstPage,
                                   left: {
                                       AttachmentsView(attachmentsUIMetadata: attachmentsMetadata.filter { $0.subtitle == AttachValue.notAttached.rawValue },
                                                       onSelectAttachment: { attachment in
                                                           cardItem = cardItems.first(where: { attachment.id.uuidString == $0.id })
                                                           firstPage = false
                                                           flowState = .confirmCard
                                                       })
                                   },
                                   right: {
                                       CardSelectionView(cardItem: cardItem, onSelect: {
                                           flowState = .beforeDrop
                                       })
                                   })
                    } else {
                        ZStack {
                            Color.clear
                            CardPreview(cardItem: cardItem)
                                .offset(y: -20)
                        }
                    }
                }
            } else {
                scanLabel(arModel.anchorPosition)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .preferredColorScheme(.dark)
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .overlay(BackButton(flowState: flowState, onAction: dismiss), alignment: .topLeading)
        .overlay(EditRow(flowState: flowState, isActive: arModel.discoveryFlowHasFinished, largButtonAction: onlargeEditAction, smallButtonAction: onSmallEditAction), alignment: .topTrailing)
        .onTapGesture {
            if flowState == .editMode || flowState == .selectMarker {
                arModel.setAllMarkerState(to: .ghost)
                sheetState = .notVisible
                flowState = .editMode
            }
        }
        .onChange(of: flowState) { newValue in
            switch newValue {
            case .arscene:
                firstPage = true
                arModel.setSelectedAnnotation(for: arModel.annotations.first)
                sheetState = .notVisible
                withAnimation { carouselVisible = true }
            case .editMode:
                sheetTitle = "View Annotation".localizedString
                arModel.setAllMarkerState(to: .ghost)
                sheetState = .notVisible
                withAnimation { carouselVisible = false }
            case .selectMarker:
                sheetState = .closed
            case .selectCard:
                sheetTitle = "Select Annotation".localizedString
                displayPagingView = true
                arModel.setAllMarkerState(to: .notVisible)
                sheetState = .open
            case .confirmCard:
                sheetTitle = "Preview Annotation".localizedString
                sheetState = .open
            case .beforeDrop:
                displayPagingView = false
                arModel.removeEntitiesFromScene()
                setAttachValue(cardItem: cardItem, attachValue: .attached)
                arModel.addNewEntity(to: cardItem)
                arModel.setMarkerState(for: cardItem, to: .world)
                sheetTitle = "View Annotation".localizedString
                sheetState = .closed
            case .dropped:
                arModel.dropEntity(for: cardItem)
                sheetState = .closed
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
    
    func onDismissDrawer() {
        self.flowState = .editMode
    }
    
    func dismiss() {
        switch self.flowState {
        case .preview:
            self.arModel.setMarkerState(for: self.cardItem, to: .world)
            self.flowState = .dropped
        default:
            if self.flowState == .beforeDrop {
                self.setAttachValue(cardItem: self.cardItem, attachValue: .notAttached)
                self.arModel.deleteEntity(for: self.cardItem)
                self.arModel.deleteCameraAnchor()
            }
            self.arModel.updateCardItemPositions()
            self.cardItems = self.arModel.annotations.map(\.card)
            self.arModel.resetAllAnchors()
            self.onDismiss?()
            self.presentationMode.wrappedValue.dismiss()
        }
    }
    
    func onlargeEditAction() {
        switch self.flowState {
        case .arscene:
            self.flowState = .editMode
        case .editMode:
            self.flowState = .arscene
        case .preview:
            if let cardItem = cardItem {
                self.arModel.reAddEntitiesToScene(exclude: [cardItem])
            }
            self.flowState = .arscene
        default:
            break
        }
    }
    
    func onSmallEditAction() {
        switch self.flowState {
        case .arscene:
            self.flowState = .editMode
        case .editMode, .beforeDrop:
            self.flowState = .selectCard
        case .selectMarker:
            self.setAttachValue(cardItem: self.cardItem, attachValue: .notAttached)
            self.arModel.deleteEntity(for: self.cardItem)
            self.cardItem = nil
            self.flowState = .editMode
        case .dropped:
            self.firstPage = true
            self.setAttachValue(cardItem: self.cardItem, attachValue: .notAttached)
            self.arModel.deleteEntity(for: self.cardItem)
            self.arModel.deleteCameraAnchor()
            if let cardItem = cardItem {
                self.arModel.reAddEntitiesToScene(exclude: [cardItem])
            }
            self.flowState = .arscene
        default:
            break
        }
    }
    
    func setAttachValue(cardItem: CardItem?, attachValue: AttachValue) {
        guard let cardItem = cardItem,
              let index = attachmentsMetadata.firstIndex(where: { $0.id.uuidString == cardItem.id }) else { return }
        self.attachmentsMetadata[index].subtitle = attachValue.rawValue
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
                    .foregroundColor(Color.preferredColor(.primaryBackground, background: .lightConstant))
                    .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
                    .cornerRadius(10)
            })
                .padding([.leading, .top], 16)
        }
    }
}

private struct EditRow: View {
    var flowState: MarkerFlowState
    var isActive: Bool
    var largButtonAction: (() -> Void)?
    var smallButtonAction: (() -> Void)?
    
    var isLargeButtonActive: Bool {
        self.flowState == .arscene || self.flowState == .editMode || self.flowState == .preview
    }
    
    var isSmallButtonActive: Bool {
        switch self.flowState {
        case .arscene, .selectCard, .confirmCard, .preview:
            return false
        default:
            return true
        }
    }
    
    var body: some View {
        if isActive {
            HStack {
                if isLargeButtonActive {
                    Button(action: {
                        largButtonAction?()
                    }, label: {
                        Text(text())
                            .font(.fiori(forTextStyle: .body).weight(.bold))
                            .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                            .frame(width: 114, height: 44)
                            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
                            .cornerRadius(10)
                    })
                }
                if isSmallButtonActive {
                    Button(action: {
                        smallButtonAction?()
                    }, label: {
                        Image(systemName: icon())
                            .font(.system(size: 19))
                            .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                            .frame(width: 44, height: 44)
                            .background(VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark)))
                            .cornerRadius(10)
                    })
                }
            }
            .padding([.top, .trailing], 16)
        }
    }
    
    func text() -> String {
        switch self.flowState {
        case .arscene:
            return "Edit Mode".localizedString
        case .editMode, .preview:
            return "Done".localizedString
        default:
            return ""
        }
    }
    
    func icon() -> String {
        switch self.flowState {
        case .editMode:
            return "plus"
        case .selectMarker, .beforeDrop, .dropped:
            return "trash"
        default:
            return ""
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
         guideImage: UIImage,
         cardAction: ((CardItem.ID) -> Void)?)
    {
        self.init(arModel: arModel,
                  cardItems: cardItems,
                  attachmentsMetadata: attachmentsMetadata,
                  onDismiss: onDismiss,
                  scanLabel: { anchorPosition in ARScanView(guideImage: guideImage, anchorPosition: anchorPosition) },
                  cardLabel: { cardItem, isSelected in CardView(model: cardItem, isSelected: isSelected, action: cardAction) },
                  markerLabel: { state, icon in MarkerView(state: state, icon: icon) })
    }
}
