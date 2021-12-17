//
//  ARCardsAuthoringControllerView.swift
//  Examples
//
//  Created by O'Brien, Patrick on 12/16/21.
//

import FioriAR
import SAPFoundation
import SwiftUI
import UIKit

struct SceneAuthoringWithUIKitView: View {
    var body: some View {
        SceneAuthoringControllerContainer()
            .navigationBarTitle("Using UIKit")
    }
}

// Implemented just to present SceneAuthoringController in Test App which is SwiftUI based
struct SceneAuthoringControllerContainer: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> ARCardsAuthoringControllerVC {
        ARCardsAuthoringControllerVC()
    }
    
    func updateUIViewController(_ uiViewController: ARCardsAuthoringControllerVC, context: Context) {}
}

class ARCardsAuthoringControllerVC: UIViewController {
    var presentSceneAuthoring: UIButton!
    
    private var sapURLSession = SAPURLSession.createOAuthURLSession(
        clientID: IntegrationTest.System.clientID,
        authURL: IntegrationTest.System.authURL,
        redirectURL: IntegrationTest.System.redirectURL,
        tokenURL: IntegrationTest.System.tokenURL
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentSceneAuthoring = UIButton()
        self.presentSceneAuthoring.setTitle("Present Scene Authoring", for: .normal)
        self.presentSceneAuthoring.setTitleColor(.white, for: .normal)
        self.presentSceneAuthoring.layer.cornerRadius = 10
        self.presentSceneAuthoring.backgroundColor = .systemBlue
        
        view.addSubview(self.presentSceneAuthoring)
        self.presentSceneAuthoring.translatesAutoresizingMaskIntoConstraints = false
        self.presentSceneAuthoring.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.presentSceneAuthoring.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -100).isActive = true
        self.presentSceneAuthoring.widthAnchor.constraint(equalToConstant: 250).isActive = true
        self.presentSceneAuthoring.heightAnchor.constraint(equalToConstant: 60).isActive = true
        self.presentSceneAuthoring.addTarget(self, action: #selector(self.presentSceneAuthoringAction), for: .touchUpInside)
    }
    
    // Use navigationController?.pushViewController()
    // Modal presenting not supported
    @objc func presentSceneAuthoringAction(sender: UIButton) {
        let sceneAuthoringController = SceneAuthoringController(title: "Annotations",
                                                                serviceURL: URL(string: IntegrationTest.System.redirectURL)!,
                                                                sapURLSession: self.sapURLSession,
                                                                sceneIdentifier: SceneIdentifyingAttribute.id(IntegrationTest.TestData.sceneId),
                                                                onSceneEdit: self.onSceneEdit)
        self.navigationController?.pushViewController(sceneAuthoringController, animated: true)
    }
    
    func onSceneEdit(sceneEdit: SceneEditing) {
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
