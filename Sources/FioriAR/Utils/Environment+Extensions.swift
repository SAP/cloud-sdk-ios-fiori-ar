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
    
    var subtitleModifier: AnyViewModifier {
        get { self[SubtitleModifierKey.self] }
        set { self[SubtitleModifierKey.self] = newValue }
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
    
    var onSceneEdit: (SceneEditing) -> Void {
        get { self[SceneEditKey.self] }
        set { self[SceneEditKey.self] = newValue }
    }
}

struct TitleModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct SubtitleModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct DetailImageModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct ActionTextModifierKey: EnvironmentKey {
    public static let defaultValue = AnyViewModifier { $0 }
}

struct CarouselOptionsKey: EnvironmentKey {
    public static let defaultValue = CarouselOptions(itemSpacing: 36, alignment: .bottom)
}

struct SceneEditKey: EnvironmentKey {
    public static let defaultValue: (SceneEditing) -> Void = { _ in }
}
