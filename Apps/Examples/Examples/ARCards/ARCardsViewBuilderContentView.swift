//
//  ARCardsViewBuilderContentView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import SwiftUI
import FioriARKit

struct ARCardsViewBuilderContentView: View {
    @StateObject var arModel = ARAnnotationViewModel<ExampleCardItem>()
    
    var body: some View {
        // TODO: Create Example using ViewBuilders
        Text("ARCardsViewBuilderExample")
    }
}
