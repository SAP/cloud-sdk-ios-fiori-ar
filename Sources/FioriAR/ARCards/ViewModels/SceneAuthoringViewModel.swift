//
//  SceneAuthoringViewModel.swift
//
//
//  Created by O'Brien, Patrick on 11/4/21.
//

import Combine
import SwiftUI

enum ARCardRequestState {
    case notStarted
    case inProgress
    case finished
    case failure
}

class SceneAuthoringModel: ObservableObject {
    @Published var cardItems: [CodableCardItem] = []
    @Published var anchorImage: UIImage? = nil
    @Published var physicalWidth: String = ""
    
    @Published var currentCardID: UUID? = nil
    @Published var currentTab: TabSelection
    @Published var attachmentsMetadata: [AttachmentUIMetadata] = []
    
    @Published var requestState: ARCardRequestState = .notStarted
    private var networkingAPI: ARCardsNetworkingService!
    private var sceneIdentifier: SceneIdentifyingAttribute?
    private var sceneId: Int? // available once scene was fetched from remote service
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkingAPI: ARCardsNetworkingService, sceneIdentifier: SceneIdentifyingAttribute?, completionHandler: (() -> Void)? = nil) {
        self.networkingAPI = networkingAPI
        self.sceneIdentifier = sceneIdentifier
        self.currentTab = sceneIdentifier == nil ? .left : .loading
        
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
                                                          subtitle: card.position_ == nil ? PinValue.notPinned.rawValue : PinValue.pinned.rawValue,
                                                          info: nil,
                                                          image: detailImage,
                                                          icon: card.icon_ == nil ? nil : Image(systemName: card.icon_!))
            attachmentsMetadata.append(newAttachmentModel)
        }
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
            self.sceneId = createdSceneId
            completionHandler(createdSceneId)
            print("Scene with id \(createdSceneId) created")
        }
        .store(in: &self.cancellables)
    }
    
    func requestSceneOnServer(sceneIdentifier: SceneIdentifyingAttribute, completionHandler: (() -> Void)? = nil) {
        self.requestState = .inProgress

        self.networkingAPI
            .getScene(sceneIdentifier)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    self.requestState = .finished
                    print(completion)
                case .failure(let error):
                    self.requestState = .failure // User Experience of Failed Fetch?
                    print("Fetching scene failed! \(error.localizedDescription)")
                }
                self.currentTab = .left
            } receiveValue: { scene in
                self.sceneId = scene.sceneId
                self.cardItems = scene.cards
                self.anchorImage = scene.referenceAnchorImage
                self.physicalWidth = String(scene.referenceAnchorImagePhysicalWidth)
                self.populateAttachmentView()
                completionHandler?()
            }
            .store(in: &self.cancellables)
    }
    
    func updateExistingSceneOnServer() {
        guard let id = sceneId,
              let anchorImage = anchorImage,
              let imageData = anchorImage.pngData(),
              let physicalWidth = Double(physicalWidth) else { return }
        
        self.networkingAPI.updateScene(
            id,
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
                print("API Error: \(error.localizedDescription)")
            }
            // User Experience of Failed Update?
        } receiveValue: { success in
            print("Updated scene with Status: \(success)")
            // User Experience of Successful Update?
        }
        .store(in: &self.cancellables)
    }
    
    func deleteSceneOnServer(completionHandler: @escaping (Int) -> Void) {}
}
