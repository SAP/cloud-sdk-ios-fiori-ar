//
//  File.swift
//
//
//  Created by O'Brien, Patrick on 4/19/21.
//

import Foundation

/// Namespace for Marker Control State
public struct MarkerControl {
    var state: MarkerControl.State = .normal

    /// Enum for Marker Control State
    public enum State {
        /// Normal State
        case normal
        /// Selected State
        case selected
        /// Ghost State
        case ghost
        /// Not Visible State
        case notVisible
        /// World State
        case world
    }
}
