//
//  Environment+Extensions.swift
//
//
//  Created by O'Brien, Patrick on 2/15/21.
//

import FioriSwiftUICore
import Foundation
import SwiftUI

public extension EnvironmentValues {
    var titleModifier: AnyViewModifier {
        get { self[TitleModifierKey.self] }
        set { self[TitleModifierKey.self] = newValue }
    }
    
    var descriptionTextModifier: AnyViewModifier {
        get { self[DescriptionTextModifierKey.self] }
        set { self[DescriptionTextModifierKey.self] = newValue }
    }
    
    var detailImageModifier: AnyViewModifier {
        get { self[DetailImageModifierKey.self] }
        set { self[DetailImageModifierKey.self] = newValue }
    }
    
    var actionTextModifier: AnyViewModifier {
        get { self[ActionTextModifierKey.self] }
        set { self[ActionTextModifierKey.self] = newValue }
    }
    
    var carouselOptions: CarouselOptions {
        get { self[CarouselOptionsKey.self] }
        set { self[CarouselOptionsKey.self] = newValue }
    }
    
    var onCardCreation: ((DecodableCardItem) -> Void)? {
        get { self[CardCreationKey.self] }
        set { self[CardCreationKey.self] = newValue }
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
    static let defaultValue = CarouselOptions(itemSpacing: 36, alignment: .bottom)
}

private struct CardCreationKey: EnvironmentKey {
    static let defaultValue: ((DecodableCardItem) -> Void)? = nil
}
