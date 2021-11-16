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
    @Environment(\.onSceneEdit) var onSceneEdit

    @StateObject private var authoringViewModel: SceneAuthoringModel
    @StateObject private var arViewModel: ARAnnotationViewModel<CodableCardItem>

    @State private var hideNavBar = true
    @State private var isCardCreationPresented = false
    @State private var isARExperiencePresented = false
    
    public init(_ cardItems: [CodableCardItem] = [], serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifyingAttribute? = nil) {
        let networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: serviceURL.absoluteString)
        _authoringViewModel = StateObject(wrappedValue: SceneAuthoringModel(cardItems, networkingAPI: networkingAPI, sceneIdentifier: sceneIdentifier))
        _arViewModel = StateObject(wrappedValue: ARAnnotationViewModel<CodableCardItem>(arManager: ARManager(canBeFatal: false))) // TODO: Back to Fatal
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            TitleBarView(title: "Annotations",
                         onLeftAction: {
                             hideNavBar = false
                             presentationMode.wrappedValue.dismiss()
                         },
                         onRightAction: {
                             if validatedSync() {
                                 // syncWithService()
                             }
                         },
                         leftBarLabel: {
                             Image(systemName: "xmark")
                                 .font(.system(size: 22))
                                 .foregroundColor(Color.black)
                         },
                         rightBarLabel: {
                             Text("Publish")
                                 .font(.system(size: 17, weight: .bold))
                                 .foregroundColor(Color.black)
                         })
                .background(Color.white)
            
            if let _ = authoringViewModel.bannerMessage {
                BannerView(message: $authoringViewModel.bannerMessage)
                    .padding([.horizontal, .bottom], 16)
            }
            
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
                    .onSceneEdit(perform: onSceneEdit),
                isActive: $isCardCreationPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .preferredColorScheme(.light)
        .navigationBarTitle("")
        .overlay(startARButton, alignment: .bottom)
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
    
    var startARButton: some View {
        Button(action: {
            if validatedAR() {
                startAR()
            }
        }, label: {
            Text("Go to AR Scene")
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(Color.white)
                .frame(width: 351, height: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.fioriNextSecondaryFill.opacity(0.24), radius: 2)
                        .shadow(color: Color.fioriNextSecondaryFill.opacity(0.08), radius: 8, y: 16)
                        .shadow(color: Color.fioriNextSecondaryFill.opacity(0.08), radius: 16, y: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.fioriNextTint)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        )
                )
        })
            .padding(.bottom, 50)
    }
    
    func validatedAR() -> Bool {
        if self.authoringViewModel.anchorImage == nil {
            withAnimation {
                authoringViewModel.bannerMessage = .anchorImageNotSelected
            }
            return false
        }
        if self.authoringViewModel.cardItems.isEmpty {
            withAnimation {
                authoringViewModel.bannerMessage = .noCardsCreated
            }
            return false
        }
        return true
    }
    
    func startAR() {
        guard let anchorImage = self.authoringViewModel.anchorImage,
              let physicalWidth = Double(self.authoringViewModel.physicalWidth) else { return }
        
        let vectorStrategy = VectorStrategy(cardContents: authoringViewModel.cardItems,
                                            anchorImage: anchorImage,
                                            physicalWidth: CGFloat(physicalWidth / 100.0))
        
        do {
            try self.arViewModel.load(loadingStrategy: vectorStrategy)
            self.isARExperiencePresented.toggle()
        } catch {
            print(error)
        }
    }
    
    func validatedSync() -> Bool {
        if !self.authoringViewModel.allAnnotationsPinned() {
            withAnimation {
                authoringViewModel.bannerMessage = .pinAnnotationsFirst
            }
            return false
        }
        return self.validatedAR() && self.authoringViewModel.hasDifference()
    }
    
    func syncWithService() {
        if let _ = authoringViewModel.sceneIdentifier {
            self.authoringViewModel.updateExistingSceneOnServer()
        } else {
            self.authoringViewModel.createSceneOnServer { sceneId in
                self.onSceneEdit(.published(sceneID: sceneId))
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
                    withAnimation { currentTab = .left }
                }
            tab(title: rightTabTitle, isSelected: currentTab == .right)
                .onTapGesture {
                    withAnimation { currentTab = .right }
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
}

enum AttachValue: String {
    case Attached
    case notAttached = "Not Attached Yet"
}
