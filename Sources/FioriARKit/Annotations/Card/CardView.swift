// SPDX-FileCopyrightText: 2021 2020 SAP SE or an SAP affiliate company and cloud-sdk-ios-fioriarkit contributors
//
// SPDX-License-Identifier: Apache-2.0

//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 4/17/21.
//

import SwiftUI
//import FioriSwiftUICore

extension Fiori {
    
    enum CardItem {
        
        struct DetailImage: ViewModifier {
            func body(content: Content) -> some View {
                content
            }
        }
        
        struct Title: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .font(.headline)
                    .foregroundColor(Color.black)
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 198, alignment: .leading)
            }
        }
        
        struct DescriptionText: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 198, alignment: .leading)
            }
        }
        
        struct ActionText: ViewModifier {
            var isSelected: Bool
            
            func body(content: Content) -> some View {
                content
                    .font(.system(size: 18))
                    .lineLimit(1)
                    .foregroundColor(isSelected ? .blue: .clear)
            }
        }
        
        typealias TitleCumulative = EmptyModifier
        typealias DescriptionTextCumulative = EmptyModifier
        typealias DetailImageCumulative = EmptyModifier
        typealias ActionTextCumulative = EmptyModifier
        
        static let title = Title()
        static let descriptionText = DescriptionText()
        static let detailImage = DetailImage()
        static let titleCumulative = TitleCumulative()
        static let descriptionTextCumulative = DescriptionTextCumulative()
        static let detailImageCumulative = DetailImageCumulative()
        static let actionTextCumulative = ActionTextCumulative()
    }
}

public struct CardView<Title: View, DescriptionText: View, DetailImage: View, ActionText: View, CardItem>: View where CardItem : CardItemModel {
    @Environment(\.titleModifier) private var titleModifier
    @Environment(\.descriptionTextModifier) private var descriptionTextModifier
    @Environment(\.detailImageModifier) private var detailImageModifer
    @Environment(\.actionTextModifier) private var actionTextModifier
    
    private let _title: Title
    private let _descriptionText: DescriptionText
    private let _detailImage: DetailImage
    private let _actionText: ActionText
    
    private var isModelInit: Bool = false
    private var isTitleNil: Bool = false
    private var isDescriptionTextNil: Bool = false
    private var isDetailImageNil: Bool = false
    private var isActionTextNil: Bool = false
    
    private var id: CardItem.ID
    private var isSelected: Bool = false
    private var action: ((CardItem.ID) -> Void)? = nil
    
    public init(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder descriptionText: @escaping () -> DescriptionText,
        @ViewBuilder detailImage: @escaping () -> DetailImage,
        @ViewBuilder actionText: @escaping () -> ActionText,
                     isSelected: Bool,
                     id: CardItem.ID,
                     action: ((CardItem.ID) -> Void)?
        ) {
        
        self._title = title()
        self._descriptionText = descriptionText()
        self._detailImage = detailImage()
        self._actionText = actionText()
        self.isSelected = isSelected
        self.id = id
        self.action = action
    }
    
    @ViewBuilder var title: some View {
        if isModelInit {
            _title.modifier(titleModifier.concat(Fiori.CardItem.title).concat(Fiori.CardItem.titleCumulative))
        } else {
            _title.modifier(titleModifier.concat(Fiori.CardItem.title))
        }
    }
    
    @ViewBuilder var descriptionText: some View {
        if isModelInit {
            _descriptionText.modifier(titleModifier.concat(Fiori.CardItem.descriptionText).concat(Fiori.CardItem.descriptionTextCumulative))
        } else {
            _title.modifier(titleModifier.concat(Fiori.CardItem.descriptionText))
        }
    }
    
    @ViewBuilder var detailImage: some View {
        if isModelInit {
            _detailImage.modifier(detailImageModifer.concat(Fiori.CardItem.detailImage).concat(Fiori.CardItem.detailImageCumulative))
        } else {
            _detailImage.modifier(detailImageModifer.concat(Fiori.CardItem.detailImage))
        }
    }
    
    @ViewBuilder var actionText: some View {
        if isModelInit {
            _actionText.modifier(actionTextModifier.concat(Fiori.CardItem.ActionText(isSelected: isSelected)).concat(Fiori.CardItem.actionTextCumulative))
        } else {
            _actionText.modifier(actionTextModifier.concat(Fiori.CardItem.ActionText(isSelected: isSelected)))
        }
    }
    
    var isTitleEmptyView: Bool {
        ((isModelInit && isTitleNil) || Title.self == EmptyView.self) ? true : false
    }

    var isDescriptionTextEmptyView: Bool {
        ((isModelInit && isDescriptionTextNil) || DescriptionText.self == EmptyView.self) ? true : false
    }
    
    var isDetailImageEmptyView: Bool {
        ((isModelInit && isDetailImageNil) || DetailImage.self == EmptyView.self) ? true : false
    }

    var isActionTextEmptyView: Bool {
        ((isModelInit && isActionTextNil) || ActionText.self == EmptyView.self) ? true : false
    }
}


extension CardView {
    
    public var body: some View {
        VStack(spacing: 10) {
            
            VStack {
                detailImage
            }
            .frame(width: 214, height: 93)
            .background(Color(red: 240/255, green: 241/255, blue: 242/255)) //Color.preferredColor(.tertiaryFill)
            .cornerRadius(10)
            .opacity(isSelected ? 1: 0.8)
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                title
                descriptionText
            }
            .padding(.bottom, 10)
            
            Button(action: {
                action?(id)
            }, label: {
                actionText
            })
            .frame(width: 198, height: isSelected && !isActionTextNil ? 44: 0)
            
        }
        .frame(width: 230)
        .background(Color.white)
        .cornerRadius(10)
        .opacity(isSelected ? 1: 0.8)
    }
}


extension CardView where
    Title == Text,
    DescriptionText == _ConditionalContent<Text, EmptyView>,
    DetailImage == _ConditionalContent<ImagePreview, DefaultIcon>,
    ActionText == _ConditionalContent<Text, EmptyView>
    {
    
    public init(model: CardItem,
                isSelected: Bool,
                action: ((CardItem.ID) -> Void)? = nil)
    {
        self.init(id: model.id,
                  title: model.title_,
                  descriptionText: model.descriptionText_,
                  detailImage: model.detailImage_,
                  actionText: model.actionText_,
                  icon: model.icon_,
                  action: action,
                  isSelected: isSelected)
    }
    
    public init(id: CardItem.ID,
                title: String,
                descriptionText: String? = nil,
                detailImage: Image? = nil,
                actionText: String? = nil,
                icon: Image?,
                action: ((CardItem.ID) -> Void)? = nil,
                isSelected: Bool)
    {
        self.id = id
        self._title = Text(title)
        self._descriptionText = descriptionText != nil ? ViewBuilder.buildEither(first: Text(descriptionText!)) : ViewBuilder.buildEither(second: EmptyView())
        self._detailImage = detailImage != nil ? ViewBuilder.buildEither(first: ImagePreview(preview: detailImage!)) : ViewBuilder.buildEither(second: DefaultIcon(icon: icon))
        self._actionText = actionText != nil ? ViewBuilder.buildEither(first: Text(actionText!)) : ViewBuilder.buildEither(second: EmptyView())
        self.action = action
        self.isSelected = isSelected

        isModelInit = true
        isTitleNil = false
        isDescriptionTextNil = descriptionText == nil ? true : false
        isDetailImageNil = detailImage == nil ? true : false
        isActionTextNil = actionText == nil ? true : false
    }
}

public struct DefaultIcon: View {
    private var icon: Image
    
    public init(icon: Image?) {
        self.icon = icon ?? Image(systemName: "info")
    }
    
    public var body: some View {
        icon
            .font(.system(size: 37))
            .foregroundColor(.gray) // Color.preferredColor(.quarternaryLabel)
    }
}

public struct ImagePreview: View {
    private var image: Image
    @State private var size: CGSize = .zero
    
    public init(preview: Image) {
        self.image = preview
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                image
                    .readSize { size in
                        self.size = size
                    }
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 10)
                    .frame(width: geo.size.width, height: geo.size.height)
                    
                if size.width < geo.size.width && size.height < geo.size.height {
                    image
                } else {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
