//
//  ARCardAuthoringContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 9/24/21.
//

import FioriARKit
import SwiftUI

struct ARCardAuthoringContentView: View {
    var body: some View {
        CardAuthoringView()
            .onCardEdit { cardEdit in
                    
                switch cardEdit {
                case .created(let card):
                    print("Created: \(card.title_)")
                case .updated(let card):
                    print("Updated: \(card.title_)")
                case .deleted(let card):
                    print("Deleted: \(card.title_)")
                }
            }
    }
}
