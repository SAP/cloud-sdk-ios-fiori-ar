//
//  CardAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import SwiftUI

public struct CardAuthoringView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var cardCreationIsPresented = false
    
    @State var currentTab: TabSelection
    
    @State var cardItems: [DecodableCardItem] = []
    @State var attachmentItemModels: [AttachmentItemModel]
    
    @State var currentCardID: UUID?
    
    public init() {
        _currentTab = State(initialValue: TabSelection.left)
        _cardItems = State(initialValue: [])
        _attachmentItemModels = State(initialValue: [])
                                        
//                                        [AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info", image: Image("Battery")),
//                                                     AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info", icon: Image(systemName: "doc")),
//                                                     AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info")])
        _currentCardID = State(initialValue: nil)
    }
    
    public var body: some View {
        VStack {
            TitleBarView(onLeftAction: {
                presentationMode.wrappedValue.dismiss()
            }, onRightAction: {
                startAR()
            }, title: "Title",
            leftBarLabel: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(Color.sapBlue)
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
                UploadAnchorImageTabView()
            }
            Spacer()
        }
        .background(NavigationLink(destination: CardCreationView(cardItems: $cardItems, currentCardID: $currentCardID), isActive: $cardCreationIsPresented, label: { EmptyView() }))
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: populateAttachmentView)
    }
    
    func startAR() {}
    
    func populateAttachmentView() {
        var attachments: [AttachmentItemModel] = []
        for attachmentItemModel in self.attachmentItemModels {
            if !self.cardItems.contains(where: { attachmentItemModel.id == UUID(uuidString: $0.id) }) {
                attachments.append(attachmentItemModel)
            }
        }
        for attach in attachments {
            self.attachmentItemModels.removeAll(where: { $0.id == attach.id })
        }
        
        for cardItem in self.cardItems {
            if !self.attachmentItemModels.contains(where: { $0.id == UUID(uuidString: cardItem.id) }) {
                self.attachmentItemModels.append(AttachmentItemModel(id: UUID(uuidString: cardItem.id) ?? UUID(),
                                                                     title: cardItem.title_,
                                                                     subtitle: cardItem.descriptionText_,
                                                                     info: nil,
                                                                     image: cardItem.detailImage_,
                                                                     icon: cardItem.icon_))
            }
        }
    }
}

// Use custom Navbar or built in?
struct TitleBarView<LeftBarLabel, RightBarLabel>: View where LeftBarLabel: View, RightBarLabel: View {
    var title: String
    var onLeftAction: (() -> Void)?
    var onRightAction: (() -> Void)?
    
    var leftBarLabel: () -> LeftBarLabel
    var rightBarLabel: () -> RightBarLabel
    
    init(onLeftAction: (() -> Void)? = nil,
         onRightAction: (() -> Void)? = nil,
         title: String,
         @ViewBuilder leftBarLabel: @escaping () -> LeftBarLabel,
         @ViewBuilder rightBarLabel: @escaping () -> RightBarLabel)
    {
        self.onLeftAction = onLeftAction
        self.onRightAction = onRightAction
        self.title = title
        self.leftBarLabel = leftBarLabel
        self.rightBarLabel = rightBarLabel
    }
    
    var body: some View {
        HStack {
            Button(action: { onLeftAction?() }, label: {
                leftBarLabel()
            })
                .padding(.leading, 16)
            Spacer()
            Text(title).bold()
            Spacer()
            Button(action: { onRightAction?() }, label: {
                rightBarLabel()
            })
                .padding(.trailing, 16)
        }
        .frame(height: 52)
        .padding(.top, 44)
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
        .padding(.top, 15)
        .padding(.horizontal, 16)
    }
    
    func tab(title: String, isSelected: Bool) -> some View {
        VStack(spacing: 6) {
            Text(title)
                .foregroundColor(isSelected ? Color.sapBlue : Color.black)
                .bold()
            if isSelected {
                Color.sapBlue.frame(height: 2)
            } else {
                Color.clear.frame(height: 2)
            }
        }
        .contentShape(Rectangle())
    }
}

extension Color {
    static let sapBlue = Color(red: 0 / 255, green: 112 / 255, blue: 242 / 255)
    static let imageGrey = Color(red: 91 / 255, green: 115 / 255, blue: 139 / 255, opacity: 0.24)
    static let fioriNextBackgroundGrey = Color(red: 245 / 255, green: 246 / 255, blue: 247 / 255, opacity: 1)
    static let fioriNextSeparatorGrey = Color(red: 91 / 255, green: 115 / 255, blue: 139 / 255, opacity: 0.83)
    static let placeholderGrey = Color(red: 91 / 255, green: 115 / 255, blue: 139 / 255, opacity: 0.83)
}

enum TabSelection {
    case left
    case right
}
