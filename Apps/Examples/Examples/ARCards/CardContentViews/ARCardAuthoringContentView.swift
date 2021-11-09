//
//  ARCardAuthoringContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 9/24/21.
//

import FioriARKit
import SAPFoundation
import SwiftUI

struct ARCardAuthoringContentView: View {
    let cardItems = [CodableCardItem(id: UUID().uuidString, title_: "Dune", subtitle_: "Arrakis", actionText_: "Watch Video", actionContentURL_: URL(string: "https://www.youtube.com/watch?v=8g18jFHCLXk")!, position_: SIMD3<Float>(x: -0.1, y: 0, z: 0)),
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
        SceneAuthoringView(serviceURL: URL(string: IntegrationTest.System.redirectURL)!,
                           sapURLSession: sapURLSession,
                           sceneIdentifier: SceneIdentifier.sceneID(id: IntegrationTest.TestData.sceneId))
            .onCardEdit { cardEdit in
                switch cardEdit {
                case .created(let card):
                    print("Created: \(card.title_)")
                case .updated(let card):
                    print("Updated: \(card.title_)")
                case .deleted(card: let card):
                    print("Deleted: \(card.title_)")
                }
            }
    }
}
