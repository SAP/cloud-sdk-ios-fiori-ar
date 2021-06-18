//
//  ExamplesApp.swift
//  Examples
//
//  Created by O'Brien, Patrick on 5/5/21.
//

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
        // Create Directories to store RealityFiles and USDZ Files in Documents Directory
        let realityDir = FileManager.default.makeDirectoryInDocumentsDirectory(FileManager.realityFiles)
        _ = FileManager.default.makeDirectoryInDocumentsDirectory(FileManager.usdzFiles)
        
        // Extract Reality File from rcprojects in the app bundle
        // Save that Reality File to Documents/RealityFiles/
        guard let extractExampleURL = Foundation.Bundle(for: ExampleRC.ExampleScene.self).url(forResource: "ExampleRC", withExtension: "reality"),
              let exampleRCData = try? Data(contentsOf: extractExampleURL) else { return true }
        
        let saveExampleURL = realityDir.appendingPathComponent("ExampleRC.reality")
        FileManager.default.saveDataToDirectory(saveExampleURL, saveData: exampleRCData)
        
        return true
    }
}
