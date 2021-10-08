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

    private var model: AnnotationSceneAuthoringModel
    
    @State private var cardCreationIsPresented = false
    
    @State private var currentTab: TabSelection
    
    @State private var anchorImage: UIImage?
    @State private var cardItems: [CodableCardItem]
    @State private var attachmentsItemModels: [AttachmentUIMetadata]
    @State private var currentCardID: UUID?
    
    @State private var hideNavBar = true
    
    public init(_ cardItems: [CodableCardItem] = [], sapURLSession: SAPURLSession) {
        _currentTab = State(initialValue: .left)
        _anchorImage = State(initialValue: nil)
        _cardItems = State(initialValue: cardItems)
        _attachmentsItemModels = State(initialValue: [])
        _currentCardID = State(initialValue: nil)
        let networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/augmentedreality/v1") // TODO: refactor baseURL out of SDK
        self.model = AnnotationSceneAuthoringModel(networkingAPI: networkingAPI)
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
                TabView(currentTab: $currentTab, leftTabTitle: "Cards", rightTabTitle: "Anchor Image")
                    .padding(.bottom, 16)
                
                switch currentTab {
                case .left:
                    AttachmentsView(label: "Cards", attachmentsUIMetadata: $attachmentsItemModels, onAddAttachment: { cardCreationIsPresented.toggle() }, onSelectAttachment: { attachmentsUIMetadata in
                        currentCardID = attachmentsUIMetadata.id
                        cardCreationIsPresented.toggle()
                    })
                case .right:
                    AnchorImageTabView(anchorImage: $anchorImage)
                }
            }
            .padding(.horizontal, verticalSizeClass == .compact ? 40 : 0)
            .background(Color.white)
        }
        .background(
            NavigationLink(destination:
                CardFormView(cardItems: $cardItems,
                             attachmentModels: $attachmentsItemModels,
                             currentCardID: $currentCardID)
                    .onCardEdit(perform: onCardEdit),
                isActive: $cardCreationIsPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .preferredColorScheme(.light)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: populateAttachmentView)
    }
    
    func populateAttachmentView() {
        self.attachmentsItemModels.removeAll()
        self.cardItems.forEach { card in
            
            var detailImage: Image?
            if let data = card.detailImage_, let uiImage = UIImage(data: data) {
                detailImage = Image(uiImage: uiImage)
            }
            
            let newAttachmentModel = AttachmentUIMetadata(id: UUID(uuidString: card.id) ?? UUID(),
                                                          title: card.title_,
                                                          subtitle: card.position_ == nil ? "Not Pinned Yet" : "Pinned",
                                                          info: nil,
                                                          image: detailImage,
                                                          icon: card.icon_ == nil ? nil : Image(card.icon_!))
            attachmentsItemModels.append(newAttachmentModel)
        }
    }
    
    func startAR() {
        if self.anchorImage != nil, !self.cardItems.isEmpty {
            print("TODO")
            self.model.createSceneOnServer(anchorImage: self.anchorImage, cards: self.cardItems)
        }
    }
}

private struct TabView: View {
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
        .font(.system(size: 14))
        .padding(.horizontal, 16)
    }
    
    func tab(title: String, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .foregroundColor(isSelected ? Color.fioriNextTint : Color.black)
                .bold()
            if isSelected {
                Color.fioriNextTint.frame(height: 2)
            } else {
                Color.clear.frame(height: 2)
            }
        }
        .contentShape(Rectangle())
    }
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
