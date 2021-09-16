//
//  CardAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import SwiftUI

public struct CardAuthoringView: View {
    @State var currentTab: TabSelection
    @State var attachmentItemModels: [AttachmentItemModel]
    
    public init() {
        _currentTab = State(initialValue: .left)
        _attachmentItemModels = State(initialValue: [AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info", image: Image("Battery")),
                                                     AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info", icon: Image(systemName: "doc")),
                                                     AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info")])
    }
    
    public var body: some View {
        VStack {
            TitleBarView(title: "Title")
                .foregroundColor(.black)
                .padding(.bottom, 5)
            
            TabView(currentTab: $currentTab, leftTabTitle: "Cards", rightTabTitle: "Anchor Image")
                .padding(.horizontal, 16)
            
            switch currentTab {
            case .left:
                AttachementsView(attachmentItemModels: $attachmentItemModels)
            case .right:
                UploadAnchorImageTabView()
            }
            Spacer()
        }
    }
}

// Use custom Navbar or built in?
struct TitleBarView: View {
    var title: String
    var onDismiss: (() -> Void)?
    var onRightBarAction: (() -> Void)?
    
    var body: some View {
        HStack {
            Button(action: { onDismiss?() }, label: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(Color.sapBlue)
            })
                .padding(.leading, 16)
            Spacer()
            Text(title).bold()
            Spacer()
            Button(action: { onRightBarAction?() }, label: {
                Image(systemName: "arkit")
                    .font(.system(size: 22))
            })
                .padding(.trailing, 16)
        }
    }
}

private struct UploadAnchorImageTabView: View {
    var onAddAnchorImage: (() -> Void)?
    
    var body: some View {
        VStack(alignment: .center, spacing: 36) {
            Text("The anchor is an image that the software can recognize to successfully place the markers in relation to the anchor. Make sure that the anchor image is scannable on the site of the experience.")
                .multilineTextAlignment(.center)
                .font(.system(size: 17))
                .padding(.horizontal, 46)
            
            Button(action: { onAddAnchorImage?() }, label: {
                Text("Upload Anchor Image")
                    .font(.system(size: 15))
                    .bold()
                    .frame(width: 187, height: 40)
                    .foregroundColor(.white)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.sapBlue)
                    )
            })
        }
        .padding(.top, 148)
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
        .padding(.top, 5)
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
}

enum TabSelection {
    case left
    case right
}
