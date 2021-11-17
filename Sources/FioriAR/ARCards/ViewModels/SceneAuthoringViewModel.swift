//
//  SceneAuthoringViewModel.swift
//
//
//  Created by O'Brien, Patrick on 11/4/21.
//

import Combine
import SwiftUI

class SceneAuthoringModel: ObservableObject {
    @Published var cardItems: [CodableCardItem] = []
    @Published var anchorImage: UIImage? = nil
    @Published var physicalWidth: String = ""
    
    @Published var currentCardID: UUID? = nil
    @Published var currentTab: TabSelection = .left
    @Published var attachmentsMetadata: [AttachmentUIMetadata] = []
    @Published var bannerMessage: BannerMessage? = nil
    @Published var validatedSync = false
    
    var sceneIdentifier: SceneIdentifyingAttribute?
    private var networkingAPI: ARCardsNetworkingService!
    private var originalCardItems: [CodableCardItem] = []
    private var originalAnchorImage: UIImage?
    private var cancellables = Set<AnyCancellable>()
    
    init(_ cardItems: [CodableCardItem] = [], networkingAPI: ARCardsNetworkingService, sceneIdentifier: SceneIdentifyingAttribute?, completionHandler: (() -> Void)? = nil) {
        self.cardItems = cardItems
        self.originalCardItems = cardItems
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
            if let data = card.detailImage_, let uiImage = UIImage(data: data) {
                detailImage = Image(uiImage: uiImage)
            }
            let newAttachmentModel = AttachmentUIMetadata(id: UUID(uuidString: card.id) ?? UUID(),
                                                          title: card.title_,
                                                          subtitle: card.position_ == nil ? AttachValue.notAttached.rawValue : AttachValue.attached.rawValue,
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
        return !currentSorted.difference(from: ogSorted).isEmpty || self.originalAnchorImage?.pngData() != self.anchorImage?.pngData()
    }
    
    func allAnnotationsPinned() -> Bool {
        self.cardItems.allSatisfy { $0.position_ != nil }
    }
    
    func validatedAR() -> Bool {
        self.anchorImage != nil && !self.cardItems.isEmpty
    }
    
    func validateSync() {
        self.validatedSync = self.hasDifference() && self.allAnnotationsPinned() && self.validatedAR()
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
                print(completion)
            case .failure(let error):
                print("Creating scene failed! \(error.localizedDescription)")
            }
        } receiveValue: { createdSceneId in
            self.sceneIdentifier = .id(createdSceneId)
            completionHandler(createdSceneId)
            print("Scene with id \(createdSceneId) created")
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
                    self.bannerMessage = .completed
                    print(completion)
                case .failure(let error):
                    self.bannerMessage = .failure
                    print("Fetching scene failed! \(error.localizedDescription)")
                }
            } receiveValue: { scene in
                self.sceneIdentifier = .id(scene.sceneId!) // TODO: two ids?
                self.cardItems = scene.cards
                self.originalCardItems = scene.cards
                self.anchorImage = scene.referenceAnchorImage
                self.originalAnchorImage = scene.referenceAnchorImage
                self.physicalWidth = String(scene.referenceAnchorImagePhysicalWidth)
                self.populateAttachmentView()
                self.validateSync()
            }
            .store(in: &self.cancellables)
    }
    
    func updateExistingSceneOnServer() {
        guard case .id(let sceneID) = self.sceneIdentifier,
              let anchorImage = anchorImage,
              let imageData = anchorImage.pngData(),
              let physicalWidth = Double(physicalWidth) else { return }
        
        self.networkingAPI.updateScene(
            sceneID,
            identifiedBy: imageData,
            anchorImagePhysicalWidth: physicalWidth,
            cards: self.cardItems
        )
        .receive(on: DispatchQueue.main)
        .sink { completion in
            switch completion {
            case .finished:
                print(completion)
                self.originalCardItems = self.cardItems
                self.originalAnchorImage = self.anchorImage
                self.bannerMessage = .sceneUpdated
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        } receiveValue: { success in
            print("Updated scene with Status: \(success)")
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
                    print(completion)
                case .failure:
                    print(completion)
                }
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
    }
}
