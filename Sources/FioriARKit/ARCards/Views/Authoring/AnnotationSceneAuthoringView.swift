//
//  AnnotationSceneAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import SwiftUI

public struct AnnotationSceneAuthoringView: View {
    @Environment(\.verticalSizeClass) var vSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onCardEdit) var onCardEdit
    
    @State private var cardCreationIsPresented = false
    
    @State private var currentTab: TabSelection
    
    @State private var anchorImage: UIImage?
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
                
                switch currentTab {
                case .left:
                    AttachementsView(label: "Cards", attachmentItemModels: $attachmentItemModels,
                                     onAddAttachment: { cardCreationIsPresented.toggle() }) { attachmentItemModel in
                        currentCardID = attachmentItemModel.id
                        cardCreationIsPresented.toggle()
                    }
                case .right:
                    UploadAnchorImageTabView(anchorImage: $anchorImage)
                    Spacer()
                }
            }
            .padding(.horizontal, vSizeClass == .compact ? 40 : 0)
            .background(Color.white)
        }
        .background(
            NavigationLink(destination:
                CardFormView(cardItems: $cardItems,
                             attachmentModels: $attachmentItemModels,
                             currentCardID: $currentCardID)
                    .onCardEdit(perform: onCardEdit),
                isActive: $cardCreationIsPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: populateAttachmentView)
    }
    
    func populateAttachmentView() {
        self.attachmentItemModels.removeAll()
        self.cardItems.forEach { card in
            let newAttachmentModel = AttachmentItemModel(id: UUID(uuidString: card.id) ?? UUID(),
                                                         title: card.title_,
                                                         subtitle: card.position_ == nil ? "Not Pinned Yet" : "Pinned",
                                                         info: nil,
                                                         image: card.detailImage_,
                                                         icon: card.icon_)
            attachmentItemModels.append(newAttachmentModel)
        }
    }
    
    func startAR() {
        if self.anchorImage == nil || self.cardItems.isEmpty {
            print("TODO")
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
        .padding(16)
    }
    
    func tab(title: String, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .foregroundColor(isSelected ? Color.fioriNextBlue : Color.black)
                .bold()
            if isSelected {
                Color.fioriNextBlue.frame(height: 2)
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
