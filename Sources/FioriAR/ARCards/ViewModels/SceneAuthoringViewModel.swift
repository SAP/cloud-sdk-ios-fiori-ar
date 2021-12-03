//
//  SceneAuthoringViewModel.swift
//
//
//  Created by O'Brien, Patrick on 11/4/21.
//

import Combine
import SAPCommon
import SwiftUI

class SceneAuthoringModel: ObservableObject {
    @Published var cardItems: [CodableCardItem] = []
    @Published var anchorImage: UIImage? = nil
    @Published var physicalWidth: String = ""
    
    @Published var currentCardID: UUID? = nil
    @Published var attachmentsMetadata: [AttachmentUIMetadata] = []
    
    @Published var currentTab: TabSelection = .left
    @Published var bannerMessage: BannerMessage? = nil
    @Published var exitMessage: ExitMessage = .beforeCreation
    @Published var isSyncValidated = false
    
    var sceneIdentifier: SceneIdentifyingAttribute?
    private var networkingAPI: ARCardsNetworkingService!
    private var originalCardItems: [CodableCardItem] = []
    private var originalAnchorImage: UIImage?
    private var originalAnchorImagePhysicalWidth: String?
    private var cancellables = Set<AnyCancellable>()

    private var logger = Logger.shared(named: "FioriAR")
    
    init(networkingAPI: ARCardsNetworkingService, sceneIdentifier: SceneIdentifyingAttribute?, completionHandler: (() -> Void)? = nil) {
        self.networkingAPI = networkingAPI
        self.sceneIdentifier = sceneIdentifier
        
        if let sceneIdentifier = sceneIdentifier {
            self.requestSceneOnServer(sceneIdentifier: sceneIdentifier)
        }
    }
    
    func populateAttachmentView() {
        self.attachmentsMetadata.removeAll()
        self.cardItems.forEach { card in
            var detailImage: Image?
            if let data = card.image_?.data, let uiImage = UIImage(data: data) {
                detailImage = Image(uiImage: uiImage)
            }
            let newAttachmentModel = AttachmentUIMetadata(id: UUID(uuidString: card.id) ?? UUID(),
                                                          title: card.title_,
                                                          subtitle: card.position_ == nil ? AttachValue.notAttached.localizedString : AttachValue.attached.localizedString,
                                                          info: nil,
                                                          image: detailImage,
                                                          icon: card.icon_ == nil ? nil : Image(systemName: card.icon_!))
            attachmentsMetadata.append(newAttachmentModel)
        }
    }
    
    func hasDifference() -> Bool {
        if self.cardItems.count != self.originalCardItems.count { return true }
        let currentSorted = self.cardItems.sorted { $0.id < $1.id }
        let ogSorted = self.originalCardItems.sorted { $0.id < $1.id }
        return !currentSorted.difference(from: ogSorted).isEmpty || self.originalAnchorImage?.pngData() != self.anchorImage?.pngData() || self.originalAnchorImagePhysicalWidth != self.physicalWidth
    }
    
    func allAnnotationsPinned() -> Bool {
        self.cardItems.allSatisfy { $0.position_ != nil }
    }
    
    func validatedAR() -> Bool {
        self.anchorImage != nil && !self.cardItems.isEmpty
    }
    
    func validateSync() {
        self.isSyncValidated = self.hasDifference() && self.allAnnotationsPinned() && self.validatedAR()
    }
    
    func validatedExit() -> Bool {
        if self.sceneIdentifier == nil {
            self.exitMessage = .beforeCreation
        } else if !self.allAnnotationsPinned() {
            self.exitMessage = .hasRemainingAnnotations
        } else if self.hasDifference() {
            self.exitMessage = .lostChanges
        } else {
            return true
        }
        return false
    }
    
    func createSceneOnServer(completionHandler: @escaping (Int) -> Void) {
        guard let anchorImage = anchorImage,
              let imageData = anchorImage.pngData(),
              let physicalWidth = Double(physicalWidth) else { return }
        
        self.networkingAPI.createScene(
            identifiedBy: imageData,
            anchorImagePhysicalWidth: physicalWidth,
            cards: self.cardItems
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                self.bannerMessage = .sceneUpdated
                self.logger.debug("createScene publisher finished")
            case .failure(let error):
                self.bannerMessage = .failure
                self.logger.error("Creating scene failed! \(error.localizedDescription)")
            }
        } receiveValue: { createdSceneId in
            self.sceneIdentifier = .id(createdSceneId)
            completionHandler(createdSceneId)
            self.logger.debug("Scene with id \(createdSceneId) created")
        }
        .store(in: &self.cancellables)
    }
    
    func requestSceneOnServer(sceneIdentifier: SceneIdentifyingAttribute) {
        self.bannerMessage = .loading

        self.networkingAPI
            .getScene(sceneIdentifier)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.bannerMessage = .syncFinished
                    self.logger.debug("getScene publisher finished")
                case .failure(let error):
                    self.bannerMessage = .failure
                    self.logger.error("Fetching scene failed! \(error.localizedDescription)")
                }
            } receiveValue: { scene in
                self.sceneIdentifier = .id(scene.sceneId)
                self.cardItems = scene.cards
                self.originalCardItems = scene.cards
                self.anchorImage = scene.referenceAnchorImage
                self.originalAnchorImage = scene.referenceAnchorImage
                self.originalAnchorImagePhysicalWidth = String(scene.referenceAnchorImagePhysicalWidth)
                self.physicalWidth = String(scene.referenceAnchorImagePhysicalWidth)
                self.populateAttachmentView()
                self.validateSync()
            }
            .store(in: &self.cancellables)
    }
    
    func updateExistingSceneOnServer(completionHandler: @escaping (Int) -> Void) {
        guard case .id(let sceneID) = self.sceneIdentifier,
              let anchorImage = anchorImage,
              let imageData = anchorImage.pngData(),
              let physicalWidth = Double(physicalWidth) else { return }

        let updatedAnchorImage: Data? = (self.originalAnchorImage?.pngData() != imageData) ? imageData : nil
        let updatedPhysicalWidth: Double? = (self.originalAnchorImagePhysicalWidth != self.physicalWidth) ? physicalWidth : nil

        let cardsToDelete = Array(originalCardItems.asIdSet.subtracting(self.cardItems.asIdSet))

        self.networkingAPI.updateScene(
            sceneID,
            identifiedBy: updatedAnchorImage,
            anchorImagePhysicalWidth: updatedPhysicalWidth,
            updateCards: self.cardItems,
            deleteCards: cardsToDelete
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                self.logger.debug("updateScene publisher finished")
                self.originalCardItems = self.cardItems
                self.originalAnchorImage = self.anchorImage
                self.originalAnchorImagePhysicalWidth = self.physicalWidth
                self.bannerMessage = .sceneUpdated
                completionHandler(sceneID)
            case .failure(let error):
                self.logger.error("Not possible to update scene: \(error.localizedDescription)")
                self.bannerMessage = .failure
            }
        } receiveValue: { success in
            self.logger.debug("Updated scene with Status: \(success)")
        }
        .store(in: &self.cancellables)
    }
    
    func deleteSceneOnServer() {
        guard case .id(let sceneId) = self.sceneIdentifier else { return }
        self.networkingAPI.deleteScene(sceneId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.logger.debug("deleteScene publishe finished")
                case .failure:
                    self.logger.error("deleteScene publishe failed")
                }
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
}
