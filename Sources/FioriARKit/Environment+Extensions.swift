//
//  File.swift
//  
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import Foundation
import SwiftUI

extension EnvironmentValues {
    public var titleModifier: AnyViewModifier {
        get { return self[TitleModifierKey.self] }
        set { self[TitleModifierKey.self] = newValue }
    }
    
    public var descriptionTextModifier: AnyViewModifier {
        get { return self[DescriptionTextModifierKey.self] }
        set { self[DescriptionTextModifierKey.self] = newValue }
    }
    
    public var detailImageModifier: AnyViewModifier {
        get { return self[DetailImageModifierKey.self] }
        set { self[DetailImageModifierKey.self] = newValue }
    }
    
    public var actionTextModifier: AnyViewModifier {
        get { return self[ActionTextModifierKey.self] }
        set { self[ActionTextModifierKey.self] = newValue }
    }
    
    public var carouselOptions: CarouselOptions {
        get { self[CarouselOptionsKey.self] }
        set { self[CarouselOptionsKey.self] = newValue }
    }
}

struct TitleModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct DescriptionTextModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct DetailImageModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct ActionTextModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct CarouselOptionsKey: EnvironmentKey {
    static let defaultValue: CarouselOptions = CarouselOptions(itemSpacing: 36, alignment: .bottom)
}
