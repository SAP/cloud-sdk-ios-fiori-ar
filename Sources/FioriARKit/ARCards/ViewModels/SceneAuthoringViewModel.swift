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
    private var sceneIdentifier: SceneIdentifier?
    
    private var cancellables = Set<AnyCancellable>()
    
    init(networkingAPI: ARCardsNetworkingService, sceneIdentifier: SceneIdentifier?, completionHandler: (() -> Void)? = nil) {
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
            completionHandler(createdSceneId)
            print("Scene with id \(createdSceneId) created")
        }
        .store(in: &self.cancellables)
    }
    
    func requestSceneOnServer(sceneIdentifier: SceneIdentifier, completionHandler: (() -> Void)? = nil) {
        // TODO: Clean up when there's support for sceneAlias
        var sceneID: Int?
        var sceneAlias: String?
        
        switch sceneIdentifier {
        case .sceneID(let id):
            sceneID = id
        case .sceneAlias(let alias):
            sceneAlias = alias
            print(sceneAlias!)
        }
        self.requestState = .inProgress
        self.networkingAPI
            .getScene(for: sceneID!)
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
                self.cardItems = scene.cards
                self.anchorImage = scene.annotationAnchorImage
                self.physicalWidth = String(scene.annotationAnchorImagePhysicalWidth)
                self.populateAttachmentView()
                completionHandler?()
            }
            .store(in: &self.cancellables)
    }
    
    func updateExistingSceneOnServer() {
        var sceneID: Int?
        var sceneAlias: String?
        
        switch self.sceneIdentifier {
        case .sceneID(let id):
            sceneID = id
        case .sceneAlias(let alias):
            sceneAlias = alias
            print(sceneAlias!)
        case .none:
            print("No Scene")
        }
        
        guard let anchorImage = anchorImage,
              let imageData = anchorImage.pngData(),
              let physicalWidth = Double(physicalWidth) else { return }
        
        self.networkingAPI.updateScene(
            sceneId: sceneID!,
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
