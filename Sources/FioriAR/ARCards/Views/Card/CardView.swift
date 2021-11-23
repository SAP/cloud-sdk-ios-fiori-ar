//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 4/17/21.
//

import FioriSwiftUICore
import FioriThemeManager
import SwiftUI

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
                    .font(.fiori(forTextStyle: .headline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 198, alignment: .leading)
            }
        }
        
        struct Subtitle: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .font(.fiori(forTextStyle: .subheadline))
                    .foregroundColor(Color.preferredColor(.secondaryLabel, background: .lightConstant))
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(width: 198, alignment: .leading)
            }
        }
        
        struct ActionText: ViewModifier {
            var isSelected: Bool
            
            func body(content: Content) -> some View {
                content
                    .font(.body)
                    .foregroundColor(self.isSelected ? Color.preferredColor(.tintColor, background: .lightConstant) : .clear)
                    .lineLimit(1)
            }
        }
        
        typealias TitleCumulative = EmptyModifier
        typealias SubtitleCumulative = EmptyModifier
        typealias DetailImageCumulative = EmptyModifier
        typealias ActionTextCumulative = EmptyModifier
        
        static let title = Title()
        static let subtitle = Subtitle()
        static let detailImage = DetailImage()
        static let titleCumulative = TitleCumulative()
        static let subtitleCumulative = SubtitleCumulative()
        static let detailImageCumulative = DetailImageCumulative()
        static let actionTextCumulative = ActionTextCumulative()
    }
}

public struct CardView<Title: View, Subtitle: View, DetailImage: View, ActionText: View, CardItem>: View where CardItem: CardItemModel {
    @Environment(\.titleModifier) private var titleModifier
    @Environment(\.subtitleModifier) private var subtitleModifier
    @Environment(\.detailImageModifier) private var detailImageModifer
    @Environment(\.actionTextModifier) private var actionTextModifier
    @Environment(\.openURL) var openURL
    
    private let _title: Title
    private let _subtitle: Subtitle
    private let _detailImage: DetailImage
    private let _actionText: ActionText
    
    private var isModelInit: Bool = false
    private var isTitleNil: Bool = false
    private var isSubtitleNil: Bool = false
    private var isDetailImageNil: Bool = false
    private var isActionTextNil: Bool = false
    
    private var id: CardItem.ID
    private var isSelected: Bool = false
    private var action: ((CardItem.ID) -> Void)?
    private var actionContentURL: URL?
    
    public init(
        @ViewBuilder title: @escaping () -> Title,
        @ViewBuilder subtitle: @escaping () -> Subtitle,
        @ViewBuilder detailImage: @escaping () -> DetailImage,
        @ViewBuilder actionText: @escaping () -> ActionText,
        isSelected: Bool,
        id: CardItem.ID,
        action: ((CardItem.ID) -> Void)?
    ) {
        self._title = title()
        self._subtitle = subtitle()
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
    
    @ViewBuilder var subtitle: some View {
        if isModelInit {
            _subtitle.modifier(subtitleModifier.concat(Fiori.CardItem.subtitle).concat(Fiori.CardItem.subtitleCumulative))
        } else {
            _subtitle.modifier(subtitleModifier.concat(Fiori.CardItem.subtitle))
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
        ((self.isModelInit && self.isTitleNil) || Title.self == EmptyView.self) ? true : false
    }

    var isSubtitleEmptyView: Bool {
        ((self.isModelInit && self.isSubtitleNil) || Subtitle.self == EmptyView.self) ? true : false
    }
    
    var isDetailImageEmptyView: Bool {
        ((self.isModelInit && self.isDetailImageNil) || DetailImage.self == EmptyView.self) ? true : false
    }

    var isActionTextEmptyView: Bool {
        ((self.isModelInit && self.isActionTextNil) || ActionText.self == EmptyView.self) ? true : false
    }
}

public extension CardView {
    var body: some View {
        VStack(spacing: 10) {
            VStack {
                detailImage
            }
            .frame(width: 214, height: 93)
            .background(Color.preferredColor(.tertiaryFill, background: .lightConstant))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .opacity(isSelected ? 1 : 0.8)
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                title
                subtitle
            }
            .padding(.bottom, 10)
            
            Button(action: {
                if let link = actionContentURL {
                    openURL(link)
                }
                action?(id)
            }, label: {
                actionText
            })
                .frame(width: 198, height: isSelected && !isActionTextNil ? 44 : 0)
        }
        .frame(width: 230)
        .background(Color.preferredColor(.primaryGroupedBackground, background: .lightConstant))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
        .opacity(isSelected ? 1 : 0.8)
    }
}

public extension CardView where
    Title == Text,
    Subtitle == _ConditionalContent<Text, EmptyView>,
    DetailImage == _ConditionalContent<ImagePreview, DefaultIcon>,
    ActionText == _ConditionalContent<Text, EmptyView>
{
    init(model: CardItem,
         isSelected: Bool,
         action: ((CardItem.ID) -> Void)? = nil)
    {
        self.init(id: model.id,
                  title: model.title_,
                  subtitle: model.subtitle_,
                  detailImage: model.detailImage_,
                  actionText: model.actionText_,
                  actionContentURL: model.actionContentURL_,
                  icon: model.icon_,
                  action: action,
                  isSelected: isSelected)
    }
    
    init(id: CardItem.ID,
         title: String,
         subtitle: String? = nil,
         detailImage: Data? = nil,
         actionText: String? = nil,
         actionContentURL: URL? = nil,
         icon: String?,
         action: ((CardItem.ID) -> Void)? = nil,
         isSelected: Bool)
    {
        var image: Image?
        if let data = detailImage, let uiImage = UIImage(data: data) {
            image = Image(uiImage: uiImage)
        }
        
        self.id = id
        self._title = Text(title)
        self._subtitle = subtitle != nil ? ViewBuilder.buildEither(first: Text(subtitle!)) : ViewBuilder.buildEither(second: EmptyView())
        self._detailImage = image != nil ? ViewBuilder.buildEither(first: ImagePreview(preview: image!)) : ViewBuilder.buildEither(second: DefaultIcon(iconString: icon))
        self._actionText = actionText != nil ? ViewBuilder.buildEither(first: Text(actionText!)) : ViewBuilder.buildEither(second: EmptyView())
        self.actionContentURL = actionContentURL
        self.action = action
        self.isSelected = isSelected

        self.isModelInit = true
        self.isTitleNil = false
        self.isSubtitleNil = subtitle == nil ? true : false
        self.isDetailImageNil = detailImage == nil ? true : false
        self.isActionTextNil = actionText == nil ? true : false
    }
}

public struct DefaultIcon: View {
    private var icon: Image
    
    public init(iconString: String?) {
        self.icon = iconString == nil ? Image(systemName: "info") : Image(systemName: iconString!)
    }
    
    public var body: some View {
        icon
            .font(.system(size: 37))
            .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
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
                    .frame(width: geo.size.width, height: geo.size.height)
                
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .blur(radius: 10)
                    .frame(width: geo.size.width, height: geo.size.height)

                if size.width < geo.size.width, size.height < geo.size.height {
                    image
                        .resizable()
                        .scaledToFit()
                } else {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}
