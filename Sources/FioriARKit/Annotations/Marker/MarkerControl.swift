//
//  File.swift
//  
//
//  Created by O'Brien, Patrick on 4/19/21.
//

import Foundation

public struct MarkerControl {
    var state: MarkerControl.State = .normal

    public enum State {
        case normal
        case selected
    }
}
