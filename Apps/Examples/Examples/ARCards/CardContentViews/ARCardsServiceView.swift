//
//  ARCardsServiceView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 10/29/21.
//

import FioriAR
import SAPFoundation
import SwiftUI

struct ARCardsServiceView: View {
    @StateObject var arModel = ARAnnotationViewModel<CodableCardItem>()
    @StateObject var asyncStrategy = ServiceStrategy<CodableCardItem>(
        serviceURL: URL(string: IntegrationTest.System.redirectURL)!,
        sapURLSession: SAPURLSession.createOAuthURLSession(
            clientID: IntegrationTest.System.clientID,
            authURL: IntegrationTest.System.authURL,
            redirectURL: IntegrationTest.System.redirectURL,
            tokenURL: IntegrationTest.System.tokenURL
        ),
        sceneIdentifier: SceneIdentifyingAttribute.id(IntegrationTest.TestData.sceneId)
    )

    var body: some View {
        ARAnnotationsView(arModel: arModel,
                          cardAction: { id in
                              // set the card action for id corresponding to the CardItemModel
                              print(id)
                          })
            .onAppear(perform: loadInitialData)
    }
    
    func loadInitialData() {
        do {
            try self.arModel.loadAsync(loadingStrategy: self.asyncStrategy)
        } catch {
            print(error)
        }
    }
}
