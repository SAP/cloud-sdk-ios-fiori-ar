//
//  FileManager+Extensions.swift
//  Examples
//
//  Created by O'Brien, Patrick on 6/21/21.
//

import Foundation

extension FileManager {
    static let realityFiles = "RealityFiles"
    static let usdzFiles = "USDZFiles"
    
    func getDocumentsDirectory() -> URL {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return URL(string: documentsDirectory)!
    }
    
    @discardableResult
    func makeDirectoryInDocumentsDirectory(_ directory: String) -> URL {
        let dataPath = self.getDocumentsDirectory().appendingPathComponent(directory)
        
        if !FileManager.default.fileExists(atPath: dataPath.path) {
            do {
                try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print(error.localizedDescription)
            }
        }
        return dataPath
    }
    
    func saveDataToDirectory(_ absoluteDirectory: URL, saveData: Data) {
        guard let absoluteDirectory = URL(string: "file://" + absoluteDirectory.path) else { print("Safe Directory Error"); return }
        
        do {
            if !FileManager.default.fileExists(atPath: absoluteDirectory.path) {
                try saveData.write(to: absoluteDirectory)
            }
        } catch {
            print("File Not Saved: \(error)")
        }
    }
}
