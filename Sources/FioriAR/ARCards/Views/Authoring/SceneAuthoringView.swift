//
//  SceneAuthoringView.swift
//
//
//  Created by O'Brien, Patrick on 9/13/21.
//

import Combine
import SAPFoundation
import SwiftUI

/**
 Provides the flow for authoring an AR Annotation Scene. Used to create the content for the cards, select an anchor Image, and position the entities in their real world locations. Publishing the scene using Mobile Services with an SAPURLSession.
 The onSceneEdit modifier provides a callback on editing events. When a scene was published, i.e. created or updated in SAP Mobile Services, then `.published(sceneID)` is called and returns the technical id of the scene.

 ## Usage
 ```
 SceneAuthoringView(title: "Car Engine",
                    serviceURL: URL(string: IntegrationTest.System.redirectURL)!,
                    sapURLSession: sapURLSession,
                    sceneIdentifier: SceneIdentifyingAttribute.id(IntegrationTest.TestData.sceneId)) // Alternative Scene: 20110993
     .onSceneEdit { sceneEdit in
         switch sceneEdit {
         case .created(card: let card):
             print("Created: \(card.title_)")
         case .updated(card: let card):
             print("Updated: \(card.title_)")
         case .deleted(card: let card):
             print("Deleted: \(card.title_)")
         case .published(sceneID: let sceneID):
             print("From SceneEdit:", sceneID)
         }
     }
 ```
 */
public struct SceneAuthoringView: View {
    @StateObject private var authoringViewModel: SceneAuthoringModel
    @StateObject private var arViewModel: ARAnnotationViewModel<CodableCardItem>

    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onSceneEdit) var onSceneEdit

    @State private var hideNavBar = true
    @State private var isCardCreationPresented = false
    @State private var isARExperiencePresented = false
    @State private var isAlertPresented = false

    let title: String

    /// Initializer
    /// - Parameters:
    ///   - title: Title of the Scene
    ///   - serviceURL: Server URL for your application in SAP Mobile Services
    ///   - sapURLSession: SAPURLSession to provide credentials to Mobile Services
    ///   - sceneIdentifier: Pass nil to create a new scene. To update a a scene you have to supply the identifier used in SAP Mobile Servcies to identify the scene.
    public init(title: String, serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifyingAttribute? = nil) {
        self.title = title
        let networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: serviceURL.absoluteString)
        _authoringViewModel = StateObject(wrappedValue: SceneAuthoringModel(networkingAPI: networkingAPI, sceneIdentifier: sceneIdentifier))
        _arViewModel = StateObject(wrappedValue: ARAnnotationViewModel<CodableCardItem>())
    }

    /// SwiftUI's view body
    public var body: some View {
        VStack(spacing: 0) {
            TitleBarView(title: title,
                         onLeftAction: {
                             if authoringViewModel.validatedExit() {
                                 dismiss()
                             } else {
                                 isAlertPresented = true
                             }
                         },
                         onRightAction: {
                             syncWithService()
                         },
                         rightDisabled: !authoringViewModel.isSyncValidated,
                         leftBarLabel: {
                             Image(systemName: "xmark")
                                 .font(.system(size: 22))
                                 .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                         },
                         rightBarLabel: {
                             Text("Publish", bundle: .fioriAR)
                                 .font(.fiori(forTextStyle: .body).weight(.bold))
                                 .foregroundColor(Color.preferredColor(authoringViewModel.isSyncValidated ? .tintColor : .separator, background: .lightConstant))
                         })
                .padding(.bottom, 6)
                .background(Color.white)

            VStack(spacing: 0) {
                TabbedView(currentTab: $authoringViewModel.currentTab, leftTabTitle: "Cards".localizedString, rightTabTitle: "Image Anchor".localizedString)
                    .padding(.bottom, 16)
                    .overlay(
                        Group {
                            if let _ = authoringViewModel.bannerMessage {
                                BannerView(message: $authoringViewModel.bannerMessage)
                                    .padding(.horizontal, 16)
                                    .offset(y: -5)
                            }
                        }
                    )

                switch authoringViewModel.currentTab {
                case .left:
                    AttachmentsView(title: "Cards".localizedString,
                                    attachmentsUIMetadata: authoringViewModel.attachmentsMetadata,
                                    onAddAttachment: { isCardCreationPresented.toggle() },
                                    onSelectAttachment: { attachmentsUIMetadata in
                                        authoringViewModel.currentCardID = attachmentsUIMetadata.id
                                        isCardCreationPresented.toggle()
                                    })
                case .right:
                    AnchorImageTabView(anchorImage: $authoringViewModel.anchorImage, physicalWidth: $authoringViewModel.physicalWidth, onDismiss: { authoringViewModel.validateSync() })
                }
            }
            .background(Color.white)
        }
        .background(
            NavigationLink(destination:
                CardFormView(cardItems: $authoringViewModel.cardItems,
                             attachmentModels: $authoringViewModel.attachmentsMetadata,
                             currentCardID: $authoringViewModel.currentCardID,
                             bannerMessage: $authoringViewModel.bannerMessage,
                             onDismiss: {
                                 authoringViewModel.validateSync()
                                 authoringViewModel.populateAttachmentView()
                             })
                    .onSceneEdit(perform: onSceneEdit),
                isActive: $isCardCreationPresented,
                label: { EmptyView() })
        )
        .navigationBarHidden(hideNavBar)
        .navigationBarTitle("")
        .preferredColorScheme(.light)
        .overlay(startARButton, alignment: .bottom)
        .edgesIgnoringSafeArea(.top)
        .onAppear(perform: authoringViewModel.populateAttachmentView)
        .fullScreenCover(isPresented: $isARExperiencePresented) {
            MarkerPositioningFlowView(arModel: arViewModel,
                                      cardItems: $authoringViewModel.cardItems,
                                      attachmentsMetadata: $authoringViewModel.attachmentsMetadata,
                                      onDismiss: { authoringViewModel.validateSync() },
                                      guideImage: authoringViewModel.anchorImage ?? UIImage(systemName: "xmark.icloud")!,
                                      cardAction: { _ in })
        }
        .alert(isPresented: $isAlertPresented) {
            Alert(title: Text("Leave Page", bundle: .fioriAR),
                  message: Text(authoringViewModel.exitMessage.localizedString),
                  primaryButton: .destructive(Text("Confirm", bundle: .fioriAR), action: {
                      dismiss()
                  }),
                  secondaryButton: .cancel())
        }
    }

    var startARButton: some View {
        Button(action: {
            startAR()
        }, label: {
            Text("Go to AR Scene", bundle: .fioriAR)
                .font(.fiori(forTextStyle: .body).weight(.bold))
                .foregroundColor(Color.preferredColor(authoringViewModel.validatedAR() ? .secondaryGroupedBackground : .separator, background: .lightConstant))
                .frame(maxWidth: .infinity, maxHeight: 54)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white)
                        .shadow(color: Color.preferredColor(.sectionShadow, background: .lightConstant), radius: 2)
                        .shadow(color: Color.preferredColor(.cardShadow, background: .lightConstant), radius: 8, y: 16)
                        .shadow(color: Color.preferredColor(.cardShadow, background: .lightConstant), radius: 16, y: 32)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.preferredColor(authoringViewModel.validatedAR() ? .tintColor : .secondaryFill, background: .lightConstant))
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                        )
                )
        })
            .disabled(!authoringViewModel.validatedAR())
            .padding(.horizontal, 12)
            .padding(.bottom, 29)
    }

    func startAR() {
        guard let anchorImage = self.authoringViewModel.anchorImage,
              let physicalWidth = Double(self.authoringViewModel.physicalWidth) else { return }

        let vectorStrategy = VectorStrategy(cardContents: authoringViewModel.cardItems,
                                            anchorImage: anchorImage,
                                            physicalWidth: physicalWidth)
        do {
            try self.arViewModel.load(loadingStrategy: vectorStrategy)
            self.isARExperiencePresented.toggle()
        } catch {
            print(error)
        }
    }

    func syncWithService() {
        if let _ = authoringViewModel.sceneIdentifier {
            self.authoringViewModel.updateExistingSceneOnServer { sceneId in
                self.onSceneEdit(.published(sceneID: sceneId))
            }
        } else {
            self.authoringViewModel.createSceneOnServer { sceneId in
                self.onSceneEdit(.published(sceneID: sceneId))
            }
        }
    }

    func dismiss() {
        self.hideNavBar = false
        self.presentationMode.wrappedValue.dismiss()
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
                .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                .foregroundColor(Color.preferredColor(isSelected ? .tintColor : .secondaryLabel, background: .lightConstant))
            if isSelected {
                Color.preferredColor(.tintColor, background: .lightConstant).frame(height: 2)
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
    case attached = "Attached"
    case notAttached = "Not Attached"

    var localizedString: String {
        self.rawValue.localizedString
    }
}

enum ExitMessage: String {
    case beforeCreation = "Are you sure you want to leave the page? Your changes will be lost."
    case hasRemainingAnnotations = "There are annotations that haven’t been attached yet. Are you sure you want to leave the app?"
    case lostChanges = "There are changes that haven’t been published yet. Are you sure you want to leave the app?"

    var localizedString: String {
        self.rawValue.localizedString
    }
}
