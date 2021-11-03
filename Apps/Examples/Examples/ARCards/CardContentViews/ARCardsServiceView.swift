//
//  ARCardsServiceView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 10/29/21.
//

import FioriARKit
import SAPFoundation
import SwiftUI

struct ARCardsServiceView: View {
    @StateObject var arModel = ARAnnotationViewModel<CodableCardItem>()
    
    var body: some View {
        ARAnnotationsView(arModel: arModel,
                          cardAction: { id in
                              // set the card action for id corresponding to the CardItemModel
                              print(id)
                          })
            .onAppear(perform: loadInitialData)
    }
    
    func loadInitialData() {
        let session = SAPURLSession()
        let sceneIdentifier = SceneIdentifier.sceneID(id: "12345")

        // if user is not yet authenticated then webview will present IdP form
        session.attachOAuthObserver(
            clientID: "d7977a0b-c0d3-474c-8d7c-dfd1e3e5245b",
            authURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/oauth2/api/v1/authorize",
            redirectURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com",
            tokenURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/oauth2/api/v1/token"
        )
        
        let asyncStrategy = ServiceStrategy<CodableCardItem>(sapURLSession: session, sceneIdentifier: sceneIdentifier)
        do {
            try self.arModel.loadAsync(loadingStrategy: asyncStrategy)
        } catch {
            print(error)
        }
    }
}
