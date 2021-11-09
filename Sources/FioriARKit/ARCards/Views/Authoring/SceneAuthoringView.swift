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

    @StateObject private var authoringViewModel: SceneAuthoringModel
    @StateObject private var arViewModel: ARAnnotationViewModel<CodableCardItem>

    @State private var hideNavBar = true
    @State private var isCardCreationPresented = false
    @State private var isARExperiencePresented = false
    
    public init(_ cardItems: [CodableCardItem] = [], serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifier? = nil) {
        let networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: serviceURL.absoluteString)
        _authoringViewModel = StateObject(wrappedValue: SceneAuthoringModel(networkingAPI: networkingAPI, sceneIdentifier: sceneIdentifier))
        _arViewModel = StateObject(wrappedValue: ARAnnotationViewModel<CodableCardItem>(arManager: ARManager(canBeFatal: false))) // TODO: Back to Fatal
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
            
            Button(action: { authoringViewModel.updateExistingSceneOnServer() }, label: {
                Text("Update Scene")
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(Color.white)
                    .frame(width: 175, height: 40, alignment: .center)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.fioriNextTint)
                    )
            })
                .padding(.vertical, 5)
            
            VStack(spacing: 0) {
                TabbedView(currentTab: $authoringViewModel.currentTab, leftTabTitle: "Cards", rightTabTitle: "Anchor Image")
                    .padding(.bottom, 16)
                
                switch authoringViewModel.currentTab {
                case .left:
                    AttachmentsView(title: "Cards",
                                    attachmentsUIMetadata: authoringViewModel.attachmentsMetadata,
                                    onAddAttachment: { isCardCreationPresented.toggle() },
                                    onSelectAttachment: { attachmentsUIMetadata in
                                        authoringViewModel.currentCardID = attachmentsUIMetadata.id
                                        isCardCreationPresented.toggle()
                                    })
                case .right:
                    AnchorImageTabView(anchorImage: $authoringViewModel.anchorImage, physicalWidth: $authoringViewModel.physicalWidth)
                case .loading:
                    ZStack {
                        Color.clear
                        if authoringViewModel.requestState == .notStarted || authoringViewModel.requestState == .inProgress {
                            ProgressView()
                        }
                    }
                }
            }
            .padding(.horizontal, verticalSizeClass == .compact ? 40 : 0)
            .background(Color.white)
        }
        .background(
            NavigationLink(destination:
                CardFormView(cardItems: $authoringViewModel.cardItems,
                             attachmentModels: $authoringViewModel.attachmentsMetadata,
                             currentCardID: $authoringViewModel.currentCardID,
                             onDismiss: { authoringViewModel.populateAttachmentView() })
                    .onCardEdit(perform: onCardEdit),
                isActive: $isCardCreationPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .preferredColorScheme(.light)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: authoringViewModel.populateAttachmentView)
        .fullScreenCover(isPresented: $isARExperiencePresented) {
            MarkerPositioningFlowView(arModel: arViewModel,
                                      cardItems: $authoringViewModel.cardItems,
                                      attachmentsMetadata: $authoringViewModel.attachmentsMetadata,
                                      image: authoringViewModel.anchorImage!,
                                      cardAction: { _ in })
        }
    }
    
    // TODO: Validate CardContents and AnchorImage. MVP Solution Disable Buttons until required data is available.
    func startAR() {
        if self.authoringViewModel.anchorImage != nil, !self.authoringViewModel.cardItems.isEmpty {
            let vectorStrategy = VectorStrategy(cardContents: authoringViewModel.cardItems,
                                                anchorImage: self.authoringViewModel.anchorImage!,
                                                physicalWidth: CGFloat(Double(self.authoringViewModel.physicalWidth)! / 100.0))
            do {
                try self.arViewModel.load(loadingStrategy: vectorStrategy)
                self.isARExperiencePresented.toggle()
            } catch {
                print(error)
            }
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

enum TabSelection {
    case left
    case right
    case loading
}

enum PinValue: String {
    case pinned = "Pinned"
    case notPinned = "Not Pinned Yet"
}
