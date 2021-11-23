import Combine
import FioriSwiftUICore
import SAPFoundation
import SwiftUI

#if DEBUG
    /**
     View capable to create a new scene, load an existing scene or delete an existing scene on/from the SAP Mobile Services AR feature

     View is not dependend on RealityKit and is not intendend to visualize the scene in the AR world.

     View is internal and maintainers of this Swift Package can change acces level temporarily and use the view in Examples app as following

     ```
     NavigationLink(destination: ARSceneRemoteViewer(sceneId: IntegrationTest.TestData.sceneId, sapURLSession: SAPURLSession.createOAuthURLSession(
         clientID: IntegrationTest.System.clientID,
         authURL: IntegrationTest.System.authURL,
         redirectURL: IntegrationTest.System.redirectURL,
         tokenURL: IntegrationTest.System.tokenURL
     ), baseURL: IntegrationTest.System.redirectURL)) {
         Text("Demo how to interact with SAP Mobile Services and its AR feature")
     }
     ```
     */
    struct ARSceneRemoteViewer: View {
        private var sceneId: Int?
        @StateObject private var model: ARSceneRemoteViewerModel
        @State private var uiImage: UIImage? = nil
        @State private var progress = 0.5

        init(sceneId: Int?, sapURLSession: SAPURLSession, baseURL: String) {
            self.sceneId = sceneId
            let networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: baseURL)
            _model = StateObject(wrappedValue: ARSceneRemoteViewerModel(networkingAPI: networkingAPI))
        }

        var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    HStack {
                        FioriButton(isSelectionPersistent: false) { _ in
                            self.model.createNewScene()
                        } title: { _ in
                            "Create new scene"
                        }
                        if let sceneId = sceneId {
                            FioriButton(isSelectionPersistent: false) { _ in
                                self.model.loadData(for: sceneId)
                            } title: { _ in
                                "Load scene"
                            }
                        }
                    }
                    if self.model.loadingStatus == .inProgress {
                        ProgressView(value: progress)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    if self.model.loadingStatus == .finished, let scene = self.model.scene {
                        FioriButton(isSelectionPersistent: false) { _ in
                            self.model.deleteScene()
                        } title: { _ in
                            "Delete scene"
                        }
                        Text("Scene \(String(scene.sceneId)) has \(scene.cards.count) cards and has \(scene.sourceFile == nil ? "no" : scene.sourceFile!.type.rawValue) source file")
                        ForEach(scene.cards, id: \.id) { card in

                            HStack {
                                CardView(model: card, isSelected: false, action: nil)
                            }
                        }
                    }
                }
                .alert(item: $model.error, content: { error in
                    Alert(
                        title: Text(error.title),
                        message: Text(error.description)
                    )
                })
                .padding()
                .frame(maxWidth: .infinity)
            }
        }
    }

    fileprivate struct ErrorInfo: Identifiable {
        var id: Int
        let title: String = "Error"
        let description: String
    }

    fileprivate enum ARSceneRemoteViewerModelDataLoading {
        case notStarted
        case inProgress
        case finished
    }

    fileprivate class ARSceneRemoteViewerModel: ObservableObject {
        private var cancellables = Set<AnyCancellable>()
        var networkingAPI: ARCardsNetworkingService!

        @Published var scene: ARScene? = nil
        @Published var error: ErrorInfo? = nil

        @Published var loadingStatus: ARSceneRemoteViewerModelDataLoading = .notStarted

        init(networkingAPI: ARCardsNetworkingService) {
            self.networkingAPI = networkingAPI
        }

        func loadData(for sceneId: Int) {
            self.loadingStatus = .inProgress

            self.networkingAPI.getScene(SceneIdentifyingAttribute.id(sceneId))
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        self.error = nil
                        self.loadingStatus = .finished
                    case .failure(let error):
                        self.error = ErrorInfo(id: 1, description: error.localizedDescription)
                        self.loadingStatus = .finished
                    }
                    print(completion)
                } receiveValue: { scene in
                    self.scene = scene
                }
                .store(in: &self.cancellables)
        }

        func createNewScene() {
            guard let anchorImage = UIImage(named: "qrImage") else { return }
            guard let anchorImageData = anchorImage.pngData() else { return }
            let dummyCard = CodableCardItem(id: UUID().uuidString, title_: "Hello", subtitle_: "Hello World", detailImage_: nil, actionText_: nil, icon_: nil)

            self.networkingAPI.createScene(
                identifiedBy: anchorImageData,
                anchorImagePhysicalWidth: 0.1,
                cards: [dummyCard]
            )
            .receive(on: DispatchQueue.main)
            .map { newSceneId in
                print("Scene with id \(newSceneId) created")
                self.loadData(for: newSceneId)
            }
            .sink { completion in
                switch completion {
                case .finished:
                    self.error = nil
                case .failure(let error):
                    self.error = ErrorInfo(id: 2, description: error.localizedDescription)
                }
                print(completion)
            } receiveValue: { _ in }
            .store(in: &self.cancellables)
        }

        func deleteScene() {
            guard let id = self.scene?.sceneId else { return }

            self.networkingAPI.deleteScene(id)
                .receive(on: DispatchQueue.main)
                .sink { completion in
                    switch completion {
                    case .finished:
                        self.error = nil
                    case .failure(let error):
                        self.error = ErrorInfo(id: 3, description: error.localizedDescription)
                    }
                    print(completion)
                } receiveValue: { _ in
                    print("Scene deleted")
                }
                .store(in: &self.cancellables)
        }
    }
#endif
