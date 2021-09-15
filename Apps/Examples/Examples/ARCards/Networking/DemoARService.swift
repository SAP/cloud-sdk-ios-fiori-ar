import Combine
import FioriARKit
import SAPFoundation
import SwiftUI

struct DemoARService: View {
    @State private var uiImage: UIImage? = nil
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
        VStack {
            Text(self.model.status)
                .frame(maxHeight: 600)
            if let image = uiImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
            }
        }.onAppear(perform: {
            self.networkingAPI.getImage(fileId: "f9d795dd-96b4-4f40-8b75-f09e0c903fdc") { result in
                switch result {
                case .success(let image):
                    self.uiImage = image
                case .failure:
                    ()
                }
            }

            self.model.loadData()
        })
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

class DemoARServiceModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var networkingAPI: ARCardsNetworkingService!

    @Published var status: String = "Fetching cards for scene..."

    init(networkingAPI: ARCardsNetworkingService) {
        self.networkingAPI = networkingAPI
    }

    func loadData() {
        self.networkingAPI.getCards(for: "A4A77E02-1C16-434F-AE04-A951EA2C6677")
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("cards fetched :)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
            } receiveValue: { cards in
                if cards.count > 0 {
                    self.status = "\(cards.count) cards are available. Details: \(cards.debugDescription)"
                } else {
                    self.status = "No cards are available."
                }
            }
            .store(in: &self.cancellables)
    }
}
