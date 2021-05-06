// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

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
