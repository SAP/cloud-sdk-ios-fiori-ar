//
//  ARCardAuthoringContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 9/24/21.
//

import FioriAR
import SAPFoundation
import SwiftUI

struct ARCardAuthoringContentView: View {
    let cardItems = [CodableCardItem(id: UUID().uuidString, title_: "Dune", subtitle_: "Arrakis", actionText_: "Watch Video", actionContentURL_: URL(string: "https://www.youtube.com/watch?v=8g18jFHCLXk")!, icon_: "link", position_: SIMD3<Float>(x: -0.1, y: 0, z: 0)),
                     CodableCardItem(id: UUID().uuidString, title_: "Harkonnen", position_: SIMD3<Float>(x: 0, y: 0, z: 0)),
                     CodableCardItem(id: UUID().uuidString, title_: "Atreides", position_: SIMD3<Float>(x: 0.1, y: 0, z: 0)),
                     CodableCardItem(id: UUID().uuidString, title_: "Foundation"),
                     CodableCardItem(id: UUID().uuidString, title_: "Gaal Dornick"),
                     CodableCardItem(id: UUID().uuidString, title_: "Hari Seldon")]

    private var sapURLSession = SAPURLSession.createOAuthURLSession(
        clientID: IntegrationTest.System.clientID,
        authURL: IntegrationTest.System.authURL,
        redirectURL: IntegrationTest.System.redirectURL,
        tokenURL: IntegrationTest.System.tokenURL
    )

    var body: some View {
        SceneAuthoringView(title: "Annotations",
                           serviceURL: URL(string: IntegrationTest.System.redirectURL)!,
                           sapURLSession: sapURLSession,
                           sceneIdentifier: SceneIdentifyingAttribute.id(IntegrationTest.TestData.sceneId)) // Alternative Scene: 20110993
            .onSceneEdit { sceneEdit in
                switch sceneEdit {
                case .created(card: let card):
                    print("Created: \(card.title_)")
                case .updated(card: let card):
                    print("Updated: \(card.title_)")
                case .deleted(card: let card):
                    print("Deleted: \(card.title_)")
                case .published(sceneID: let sceneID):
                    print("From SceneEdit:", sceneID)
                }
            }
    }
}
