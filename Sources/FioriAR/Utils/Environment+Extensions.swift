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
    /// view modifier influencing `CardView` and its title
    var titleModifier: AnyViewModifier {
        get { self[TitleModifierKey.self] }
        set { self[TitleModifierKey.self] = newValue }
    }

    /// view modifier influencing `CardView` and its subtitle
    var subtitleModifier: AnyViewModifier {
        get { self[SubtitleModifierKey.self] }
        set { self[SubtitleModifierKey.self] = newValue }
    }

    /// view modifier influencing `CardView` and its detail / cover image
    var detailImageModifier: AnyViewModifier {
        get { self[DetailImageModifierKey.self] }
        set { self[DetailImageModifierKey.self] = newValue }
    }

    /// view modifier influencing `CardView` and its action text
    var actionTextModifier: AnyViewModifier {
        get { self[ActionTextModifierKey.self] }
        set { self[ActionTextModifierKey.self] = newValue }
    }

    /// view modifier influencing `CarouselScrollView` and its carousel options
    var carouselOptions: CarouselOptions {
        get { self[CarouselOptionsKey.self] }
        set { self[CarouselOptionsKey.self] = newValue }
    }

    /// view modifier providing a callback on editing events
    var onSceneEdit: (SceneEditing) -> Void {
        get { self[SceneEditKey.self] }
        set { self[SceneEditKey.self] = newValue }
    }
    
    var safeAreaInsets: EdgeInsets {
        self[SafeAreaInsetsKey.self]
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

struct SafeAreaInsetsKey: EnvironmentKey {
    public static var defaultValue: EdgeInsets { (UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.safeAreaInsets ?? .zero).insets }
}
