//
//  ExamplesApp.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

import FioriAR
import SAPCommon
import SwiftUI

@main
struct ExamplesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // Register FioriNext Fonts
        Font.registerFioriFonts()
        
        // Create Directories to store RealityFiles and USDZ Files in Documents Directory
        let realityDir = FileManager.default.makeDirectoryInDocumentsDirectory(FileManager.realityFiles)
        let usdzDir = FileManager.default.makeDirectoryInDocumentsDirectory(FileManager.usdzFiles)
        
        // Extract Reality File and USDZ file from app bundle
        // Turn the path file into Data
        guard let extractExampleRealityURL = Foundation.Bundle(for: ExampleRC.ExampleScene.self).url(forResource: "ExampleRC", withExtension: "reality"),
              let exampleRCRealityData = try? Data(contentsOf: extractExampleRealityURL),
              let extractExampleUsdzURL = Foundation.Bundle.main.url(forResource: "ExampleRC", withExtension: "usdz"),
              let exampleRCUsdzData = try? Data(contentsOf: extractExampleUsdzURL) else { return true }
        
        // Save that Reality File and USDZ file to Documents/RealityFiles/ and Documents/USDZFiles/ repsectively
        let saveExampleRealityURL = realityDir.appendingPathComponent("ExampleRC.reality")
        let saveExampleUsdzURL = usdzDir.appendingPathComponent("ExampleRC.usdz")
            
        FileManager.default.saveDataToDirectory(saveExampleRealityURL, saveData: exampleRCRealityData)
        FileManager.default.saveDataToDirectory(saveExampleUsdzURL, saveData: exampleRCUsdzData)

        // activate logging either for FioriAR specific logger or for all loggers (incl. SAPFoundation)
        // Logger.shared(named: "FioriAR").logLevel = .debug
        // Logger.root.logLevel = .debug // all loggers, incl. SAPFoundation

        return true
    }
}
