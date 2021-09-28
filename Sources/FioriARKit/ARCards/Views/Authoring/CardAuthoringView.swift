//
//  CardAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import SwiftUI

public struct CardAuthoringView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onCardEdit) var onCardEdit
    
    @State private var cardCreationIsPresented = false
    
    @State private var currentTab: TabSelection
    
    @State private var anchorImage: Image?
    @State private var cardItems: [DecodableCardItem]
    @State private var attachmentItemModels: [AttachmentItemModel]
    @State private var currentCardID: UUID?
    
    @State private var hideNavBar = true
    
    public init(_ cardItems: [DecodableCardItem] = []) {
        _currentTab = State(initialValue: .left)
        _anchorImage = State(initialValue: nil)
        _cardItems = State(initialValue: cardItems)
        _attachmentItemModels = State(initialValue: [])
        _currentCardID = State(initialValue: nil)
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TitleBarView(onLeftAction: {
                hideNavBar = false
                presentationMode.wrappedValue.dismiss()
            }, onRightAction: {
                startAR()
            }, title: "Title",
            leftBarLabel: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(Color.fnBlue)
            },
            rightBarLabel: {
                Image(systemName: "arkit")
                    .font(.system(size: 22))
            })
                .background(Color.white)
            
            TabView(currentTab: $currentTab, leftTabTitle: "Cards", rightTabTitle: "Anchor Image")
            
            switch currentTab {
            case .left:
                AttachementsView(attachmentItemModels: $attachmentItemModels, onAddAttachment: { cardCreationIsPresented.toggle() }) { attachmentItemModel in
                    currentCardID = attachmentItemModel.id
                    cardCreationIsPresented.toggle()
                }
            case .right:
                UploadAnchorImageTabView(anchorImage: $anchorImage)
            }
            Spacer()
        }
        .background(
            NavigationLink(destination:
                CardCreationView(cardItems: $cardItems,
                                 attachmentModels: $attachmentItemModels,
                                 currentCardID: $currentCardID)
                    .onCardEdit(perform: onCardEdit),
                           
                isActive: $cardCreationIsPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: populateAttachmentView)
    }
    
    func populateAttachmentView() {
        self.cardItems.forEach { card in
            if !attachmentItemModels.contains(where: { UUID(uuidString: card.id) == $0.id }) {
                let newAttachmentModel = AttachmentItemModel(id: UUID(uuidString: card.id) ?? UUID(),
                                                             title: card.title_,
                                                             subtitle: card.descriptionText_,
                                                             info: nil,
                                                             image: card.detailImage_,
                                                             icon: card.icon_)
                attachmentItemModels.append(newAttachmentModel)
            }
        }
    }
    
    func startAR() {}
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
        .padding(16)
    }
    
    func tab(title: String, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .foregroundColor(isSelected ? Color.fnBlue : Color.black)
                .bold()
            if isSelected {
                Color.fnBlue.frame(height: 2)
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
