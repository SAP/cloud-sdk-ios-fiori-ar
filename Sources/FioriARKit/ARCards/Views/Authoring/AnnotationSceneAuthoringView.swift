//
//  AnnotationSceneAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import SwiftUI

public struct AnnotationSceneAuthoringView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onCardEdit) var onCardEdit
    
    @State private var cardCreationIsPresented = false
    
    @State private var currentTab: TabSelection
    
    @State private var anchorImage: UIImage?
    @State private var cardItems: [DecodableCardItem]
    @State private var attachmentsItemModels: [AttachmentsItemModel]
    @State private var currentCardID: UUID?
    
    @State private var hideNavBar = true
    
    public init(_ cardItems: [DecodableCardItem] = []) {
        _currentTab = State(initialValue: .left)
        _anchorImage = State(initialValue: nil)
        _cardItems = State(initialValue: cardItems)
        _attachmentsItemModels = State(initialValue: [])
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
                    .padding(.bottom, 16)
                
                switch currentTab {
                case .left:
                    AttachmentsView(label: "Cards", attachmentsItemModels: $attachmentsItemModels, onAddAttachment: { cardCreationIsPresented.toggle() }) { attachmentsItemModel in
                        currentCardID = attachmentsItemModel.id
                        cardCreationIsPresented.toggle()
                    }
                case .right:
                    UploadAnchorImageTabView(anchorImage: $anchorImage)
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
            let newAttachmentModel = AttachmentsItemModel(id: UUID(uuidString: card.id) ?? UUID(),
                                                          title: card.title_,
                                                          subtitle: card.position_ == nil ? "Not Pinned Yet" : "Pinned",
                                                          info: nil,
                                                          image: card.detailImage_,
                                                          icon: card.icon_)
            attachmentsItemModels.append(newAttachmentModel)
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
