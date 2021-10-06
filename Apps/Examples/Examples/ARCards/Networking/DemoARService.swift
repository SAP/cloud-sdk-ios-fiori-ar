import Combine
import FioriARKit
import SAPFoundation
import SwiftUI

struct DemoARService: View {
    @State private var uiImage: UIImage? = nil
    private var sceneId = "A4A77E02-1C16-434F-AE04-A951EA2C6633"
    private var networkingAPI: ARCardsNetworkingService
    @ObservedObject private var model: DemoARServiceModel
    
    init() {
        let sapURLSession = SAPURLSession()
        
        // if user is not yet authenticated then webview will present IdP form
        sapURLSession.attachOAuthObserver(
            clientID: "d7977a0b-c0d3-474c-8d7c-dfd1e3e5245b",
            authURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/oauth2/api/v1/authorize",
            redirectURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com",
            tokenURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/oauth2/api/v1/token"
        )
        
        self.networkingAPI = ARCardsNetworkingService(sapURLSession: sapURLSession, baseURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/augmentedreality/v1")

        self.model = DemoARServiceModel(networkingAPI: self.networkingAPI)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Button("Create new scene") {
                    self.model.createNewScene()
                }
                if self.model.loadingStatus == .finished, let scene = self.model.scene {
                    Text("Scene \(scene.sceneId) has \(scene.cards.count) cards and has \(scene.sourceFile == nil ? "no" : scene.sourceFile!.type.rawValue) source file")
                    ForEach(scene.cards, id: \.self) { card in
                        HStack {
                            Text("\(scene.cards.firstIndex(of: card)! + 1). \(card.title_)")
                            if let image = card.detailImage_ {
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                            } else {
                                EmptyView().frame(width: 100, height: 100)
                            }
                        }
                    }
                } else {
                    Text("Fetching cards for scene \(sceneId) ...")
                }
            }.onAppear(perform: {
                self.model.loadData(for: sceneId)

            })
                .frame(maxWidth: .infinity)
        }
    }
}

extension DecodableCardItem: Hashable {
    public static func == (lhs: DecodableCardItem, rhs: DecodableCardItem) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct DemoARService_Previews: PreviewProvider {
    static var previews: some View {
        DemoARService()
    }
}

extension SAPURLSession {
    func attachOAuthObserver(clientID: String, authURL: String, redirectURL: String, tokenURL: String) {
        let secureKeyValueStore = SecureKeyValueStore()
        try! secureKeyValueStore.open(with: "downloadAR_secure_store")
        let compositeStore = CompositeStorage()
        try! compositeStore.setPersistentStore(secureKeyValueStore)
        
        if let authorizationEndpointURL = URL(string: authURL),
           let redirectURL = URL(string: redirectURL),
           let tokenEndpointURL = URL(string: tokenURL)
        {
            let params = OAuth2AuthenticationParameters(authorizationEndpointURL: authorizationEndpointURL,
                                                        clientID: clientID,
                                                        redirectURL: redirectURL,
                                                        tokenEndpointURL: tokenEndpointURL)
            
            let authenticator = OAuth2Authenticator(authenticationParameters: params, webViewPresenter: WKWebViewPresenter())
            let oauthObserver = OAuth2Observer(authenticator: authenticator, tokenStore: OAuth2TokenStorage(store: compositeStore))
            
            self.register(oauthObserver)
        }
    }
}

enum DemoARServiceModelDataLoading {
    case notStarted
    case inProgress
    case finished
}

class DemoARServiceModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var networkingAPI: ARCardsNetworkingService!

    // @Published var cards: [DecodableCardItem] = []
    @Published var scene: ARScene? = nil

    @Published var loadingStatus: DemoARServiceModelDataLoading = .notStarted

    init(networkingAPI: ARCardsNetworkingService) {
        self.networkingAPI = networkingAPI
    }

    func loadData(for sceneId: String) {
        self.loadingStatus = .inProgress
        //        self.networkingAPI.getCards(for: sceneId)
        //            .receive(on: DispatchQueue.main)
        //            .sink { completion in
        //                print(completion)
        //            } receiveValue: { cards in
        //                self.cards = cards
        //                self.loadingStatus = .finished
        //            }
        //            .store(in: &self.cancellables)

        self.networkingAPI.getScene(for: sceneId)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                print(completion)
            } receiveValue: { scene in
                self.scene = scene
                self.loadingStatus = .finished
            }
            .store(in: &self.cancellables)
    }

    func createNewScene() {
        guard let anchorImage = UIImage(named: "qrImage") else { return }
        guard let anchorImageData = anchorImage.pngData() else { return }
        let dummyCard = DecodableCardItem(id: UUID().uuidString, title_: "Hello", descriptionText_: "Hello World", detailImage_: nil, actionText_: nil, icon_: nil)


        self.networkingAPI.createScene(
            identfiedBy: anchorImageData,
            anchorImagePhysicalWidth: 0.1,
            cards: [dummyCard]
        )
        .receive(on: DispatchQueue.main)
        .map { newSceneId in
            self.loadData(for: newSceneId)
        }
        .sink { completion in
            print(completion)
        } receiveValue: { createdSceneId in
            print("Scene with id \(createdSceneId) created")
        }
        .store(in: &self.cancellables)
    }
}
