//
//  SceneAuthoringController.swift
//
//
//  Created by O'Brien, Patrick on 12/16/21.
//

import SAPFoundation
import SwiftUI

/**
 Provides the flow for authoring an AR Annotation Scene using UIKit. Used to create the content for the cards, select an anchor Image, and position the entities in their real world locations. Publishing the scene using Mobile Services with an SAPURLSession.
 The onSceneEdit modifier provides a callback on editing events. When a scene was published, i.e. created or updated in SAP Mobile Services, then `.published(sceneID)` is called and returns the technical id of the scene.
 Note: Push onto a navigation stack, modal presenting not supported

 ## Usage
 ```
 @objc func launchSceneAuthoring(sender: UIButton) {
     let sceneAuthoringController = SceneAuthoringController(title: "Annotations",
                                                             serviceURL:  URL(string: IntegrationTest.System.redirectURL)!,
                                                             sapURLSession: sapURLSession,
                                                             sceneIdentifier: SceneIdentifyingAttribute.id(IntegrationTest.TestData.sceneId))
     self.navigationController?.pushViewController(sceneAuthoringController, animated: true)
 }
 ```
 */
public class SceneAuthoringController: UIHostingController<SceneAuthoringView> {
    /// Initializer
    /// - Parameters:
    ///   - title: Title of the Scene
    ///   - serviceURL: SAPURLSession to provide credentials to Mobile Services
    ///   - sapURLSession: If nil then a new scene is created.
    ///   - sceneIdentifier: Pass nil to create a new scene. To update a a scene you have to supply the identifier used in SAP Mobile Servcies to identify the scene.
    public init(title: String, serviceURL: URL, sapURLSession: SAPURLSession, sceneIdentifier: SceneIdentifyingAttribute? = nil) {
        super.init(rootView: SceneAuthoringView(title: title, serviceURL: serviceURL, sapURLSession: sapURLSession, sceneIdentifier: sceneIdentifier))
    }
    
    @available(*, unavailable)
    @objc dynamic required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
