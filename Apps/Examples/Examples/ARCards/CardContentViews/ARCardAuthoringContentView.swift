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
    let cardItems = [DecodableCardItem(id: UUID().uuidString, title_: "Hello"),
                     DecodableCardItem(id: UUID().uuidString, title_: "World"),
                     DecodableCardItem(id: UUID().uuidString, title_: "Fizz"),
                     DecodableCardItem(id: UUID().uuidString, title_: "Buzz")]

    private var sapURLSession: SAPURLSession

    init() {
        sapURLSession = SAPURLSession()

        // if user is not yet authenticated then webview will present IdP form
        sapURLSession.attachOAuthObserver(
            clientID: "d7977a0b-c0d3-474c-8d7c-dfd1e3e5245b",
            authURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/oauth2/api/v1/authorize",
            redirectURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com",
            tokenURL: "https://mobile-tenant1-xudong-iosarcards.cfapps.sap.hana.ondemand.com/oauth2/api/v1/token"
        )
    }

    var body: some View {
        AnnotationSceneAuthoringView(cardItems, sapURLSession: sapURLSession)
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
