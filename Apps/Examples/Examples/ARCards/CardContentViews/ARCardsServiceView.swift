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
                          scanLabel: { guideImageState, anchorPosition in
                              CustomScanView(guideImageState: guideImageState, position: anchorPosition)
                          },
                          cardLabel: { cardmodel, isSelected in
                              CustomCardView(model: cardmodel, isSelected: isSelected)
                          },
                          markerLabel: { state, _ in
                              CustomMarkerView(state: state)
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
