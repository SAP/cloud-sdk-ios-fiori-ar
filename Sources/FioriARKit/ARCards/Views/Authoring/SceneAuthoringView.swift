//
//  AnnotationSceneAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import Combine
import SAPFoundation
import SwiftUI

public struct SceneAuthoringView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onCardEdit) var onCardEdit

    @StateObject private var networkModel: AnnotationSceneAuthoringModel
    @StateObject private var arModel: ARAnnotationViewModel<CodableCardItem>
    
    @State private var currentTab: TabSelection = .left
    @State private var hideNavBar = true

    @State private var isCardCreationPresented = false
    @State private var isARExperiencePresented = false
    
    @State private var anchorImage: UIImage? = nil
    @State private var physicalWidth: String = ""
    @State private var cardItems: [CodableCardItem]
    @State private var attachmentsMetadata: [AttachmentUIMetadata] = []
    @State private var currentCardID: UUID? = nil
    
    public init(_ cardItems: [CodableCardItem] = [], sapURLSession: SAPURLSession) {
        _cardItems = State(initialValue: cardItems)
        let networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/augmentedreality/v1")
        // TODO: refactor baseURL out of SDK
        _networkModel = StateObject(wrappedValue: AnnotationSceneAuthoringModel(networkingAPI: networkingAPI))
        _arModel = StateObject(wrappedValue: ARAnnotationViewModel<CodableCardItem>(arManager: ARManager(canBeFatal: false))) // TODO: Back to Fatal
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TitleBarView(title: "Title",
                         onLeftAction: {
                             hideNavBar = false
                             presentationMode.wrappedValue.dismiss()
                         },
                         onRightAction: {
                             startAR()
                         },
                         leftBarLabel: {
                             Image(systemName: "xmark")
                                 .font(.system(size: 22))
                                 .foregroundColor(Color.black)
                         },
                         rightBarLabel: {
                             Image(systemName: "arkit")
                                 .font(.system(size: 22))
                                 .foregroundColor(Color.black)
                         })
                .background(Color.white)
            
            VStack(spacing: 0) {
                TabbedView(currentTab: $currentTab, leftTabTitle: "Cards", rightTabTitle: "Anchor Image")
                    .padding(.bottom, 16)
                
                switch currentTab {
                case .left:
                    AttachmentsView(title: "Cards",
                                    attachmentsUIMetadata: attachmentsMetadata,
                                    onAddAttachment: { isCardCreationPresented.toggle() },
                                    onSelectAttachment: { attachmentsUIMetadata in
                                        currentCardID = attachmentsUIMetadata.id
                                        isCardCreationPresented.toggle()
                                    })
                case .right:
                    AnchorImageTabView(anchorImage: $anchorImage, physicalWidth: $physicalWidth)
                }
            }
            .padding(.horizontal, verticalSizeClass == .compact ? 40 : 0)
            .background(Color.white)
        }
        .background(
            NavigationLink(destination:
                CardFormView(cardItems: $cardItems,
                             attachmentModels: $attachmentsMetadata,
                             currentCardID: $currentCardID,
                             onDismiss: { self.populateAttachmentView() })
                    .onCardEdit(perform: onCardEdit),
                isActive: $isCardCreationPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .preferredColorScheme(.light)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: populateAttachmentView)
        .fullScreenCover(isPresented: $isARExperiencePresented) {
            MarkerPositioningFlowView(arModel: arModel,
                                      cardItems: $cardItems,
                                      attachmentsMetadata: $attachmentsMetadata,
                                      image: Image(uiImage: anchorImage!),
                                      cardAction: { _ in })
        }
    }
    
    func populateAttachmentView() {
        self.attachmentsMetadata.removeAll()
        self.cardItems.forEach { card in
            var detailImage: Image?
            if let data = card.detailImage_, let uiImage = UIImage(data: data) {
                detailImage = Image(uiImage: uiImage)
            }
            let newAttachmentModel = AttachmentUIMetadata(id: UUID(uuidString: card.id) ?? UUID(),
                                                          title: card.title_,
                                                          subtitle: card.position_ == nil ? PinValue.notPinned.rawValue : PinValue.pinned.rawValue,
                                                          info: nil,
                                                          image: detailImage,
                                                          icon: card.icon_ == nil ? nil : Image(card.icon_!))
            attachmentsMetadata.append(newAttachmentModel)
        }
    }
    
    func startAR() {
        if self.anchorImage != nil || !self.cardItems.isEmpty {
            let vectorStrategy = VectorLoadingStrategy(cardContents: cardItems,
                                                       anchorImage: anchorImage!,
                                                       physicalWidth: CGFloat(Double(physicalWidth)! / 100.0))
            arModel.load(loadingStrategy: vectorStrategy)
            self.isARExperiencePresented.toggle()
        }
    }
}

private struct TabbedView: View {
    @Binding var currentTab: TabSelection
    
    var leftTabTitle: String
    var rightTabTitle: String
    
    var body: some View {
        HStack(spacing: 0) {
            tab(title: leftTabTitle, isSelected: currentTab == .left)
                .onTapGesture {
                    currentTab = .left
                }
            tab(title: rightTabTitle, isSelected: currentTab == .right)
                .onTapGesture {
                    currentTab = .right
                }
        }
        .font(.system(size: 14, weight: .bold))
        .padding(.horizontal, 16)
    }
    
    func tab(title: String, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .foregroundColor(isSelected ? Color.fioriNextTint : Color.black)
            if isSelected {
                Color.fioriNextTint.frame(height: 2)
            } else {
                Color.clear.frame(height: 2)
            }
        }
        .contentShape(Rectangle())
    }
}

enum PinValue: String {
    case pinned = "Pinned"
    case notPinned = "Not Pinned Yet"
}

private enum TabSelection {
    case left
    case right
}

class AnnotationSceneAuthoringModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var networkingAPI: ARCardsNetworkingService!

    init(networkingAPI: ARCardsNetworkingService) {
        self.networkingAPI = networkingAPI
    }

    func createSceneOnServer(anchorImage: UIImage?, cards: [CodableCardItem]) {
        guard let anchorImage = anchorImage else { return }
        guard let anchorImageData = anchorImage.pngData() else { return }

        self.networkingAPI.createScene(
            identfiedBy: anchorImageData,
            anchorImagePhysicalWidth: 0.1,
            cards: cards
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            print(completion)
        } receiveValue: { createdSceneId in
            print("Scene with id \(createdSceneId) created")
        }
        .store(in: &self.cancellables)
    }
}
