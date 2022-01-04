//
//  CardCreationView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import Combine
import FioriCharts
import SwiftUI

/// Callbacks during scene authoring
public enum SceneEditing {
    /// a card was locally created
    case created(card: CodableCardItem)
    /// a card was locally updated
    case updated(card: CodableCardItem)
    /// a card was locally deleted
    case deleted(card: CodableCardItem)
    /// the scene was either created or updated remotely
    case published(sceneID: Int)
}

struct CardFormView: View {
    @Environment(\.safeAreaInsets) var safeAreaInsets
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onSceneEdit) var onSceneEdit

    @Binding var cardItems: [CodableCardItem]
    @Binding var attachmentModels: [AttachmentUIMetadata]
    @Binding var currentCardID: UUID?
    @Binding var bannerMessage: BannerMessage?
    
    @State var detailImage: CardImage?
    @State var title: String
    @State var subtitle: String
    @State var actionText: String
    @State var actionContentText: String
    @State var icon: String?
    @State var hasButton = false
    @State var hasCoverImage = false

    var isUpdate: Bool = false
    var onDismiss: (() -> Void)?

    init(cardItems: Binding<[CodableCardItem]>,
         attachmentModels: Binding<[AttachmentUIMetadata]>,
         currentCardID: Binding<UUID?>,
         bannerMessage: Binding<BannerMessage?>,
         onDismiss: (() -> Void)?)
    {
        self._cardItems = cardItems
        self._attachmentModels = attachmentModels
        self._currentCardID = currentCardID
        self._bannerMessage = bannerMessage

        let currentCard = cardItems.wrappedValue.first(where: { $0.id == currentCardID.wrappedValue?.uuidString })

        self._detailImage = State(initialValue: currentCard?.image_ ?? CardImage.new)
        self._title = State(initialValue: currentCard?.title_ ?? "")
        self._subtitle = State(initialValue: currentCard?.subtitle_ ?? "")
        self._actionText = State(initialValue: currentCard?.actionText_ ?? "")
        self._actionContentText = State(initialValue: currentCard?.actionContentURL_?.absoluteString ?? "")
        self._icon = State(initialValue: currentCard?.icon_)

        self._hasButton = State(initialValue: currentCard?.actionText_ == nil ? false : true)
        self._hasCoverImage = State(initialValue: currentCard?.image_?.data == nil ? false : true)

        self.isUpdate = currentCardID.wrappedValue == nil ? false : true
        self.onDismiss = onDismiss
    }

    var body: some View {
        VStack(spacing: 0) {
            TitleBarView(title: isUpdate ? title : "New Annotation".localizedString,
                         onLeftAction: {
                             presentationMode.wrappedValue.dismiss()
                         },
                         onRightAction: {
                             if let currentID = currentCardID {
                                 deleteCard(for: currentID)
                             }
                             presentationMode.wrappedValue.dismiss()
                         },
                         leftBarLabel: {
                             Image(systemName: "xmark")
                                 .font(.system(size: 22))
                                 .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                         },
                         rightBarLabel: {
                             if let _ = currentCardID {
                                 Image(systemName: "trash")
                                     .font(.system(size: 22))
                                     .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                             }
                         })
                .padding(.leading, safeAreaInsets.leading)
                .padding(.trailing, safeAreaInsets.trailing)
                .background(Color.preferredColor(.primaryGroupedBackground, background: .lightConstant))

            AdaptiveStack {
                ZStack {
                    Color.preferredColor(.primaryGroupedBackground, background: .lightConstant)
                    CardPreview(detailImage: .constant(detailImage?.data),
                                title: $title,
                                subtitle: $subtitle,
                                actionText: $actionText,
                                actionContentText: $actionContentText,
                                icon: $icon,
                                hasButton: $hasButton)
                        .offset(y: verticalSizeClass == .compact ? -70 : -10)
                }
                .frame(maxHeight: verticalSizeClass == .compact ? .infinity : 246)

                CardDetailsView(title: $title,
                                subtitle: $subtitle,
                                detailImage: $detailImage,
                                actionText: $actionText,
                                actionContentText: $actionContentText,
                                actionButtonToggle: $hasButton,
                                coverImageToggle: $hasCoverImage,
                                isUpdate: isUpdate,
                                editCardAction: {
                                    if let currentID = currentCardID {
                                        updateCard(for: currentID)
                                    } else {
                                        createCard()
                                    }
                                    presentationMode.wrappedValue.dismiss()
                                })
            }
            .padding(.leading, safeAreaInsets.leading)
            .padding(.trailing, safeAreaInsets.trailing)
        }
        .onChange(of: actionContentText) { newValue in
            icon = newValue.isEmpty ? nil : "link"
        }
        .onDisappear {
            onDismiss?()
            currentCardID = nil
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .background(Color.preferredColor(.primaryGroupedBackground, background: .lightConstant))
        .edgesIgnoringSafeArea(verticalSizeClass == .compact ? [.horizontal, .bottom] : .vertical)
        .ignoresSafeArea(.keyboard)
    }

    func createCard() {
        let newCard = CodableCardItem(id: UUID().uuidString,
                                      title_: self.title,
                                      subtitle_: self.subtitle.isEmpty ? nil : self.subtitle,
                                      image: self.detailImage,
                                      actionText_: self.actionText.isEmpty ? nil : self.actionText,
                                      actionContentURL_: URL(string: self.actionContentText),
                                      icon_: self.actionContentText.isEmpty ? nil : "link")

        self.cardItems.append(newCard)
        self.onSceneEdit(.created(card: newCard))
        self.bannerMessage = .cardCreated
    }

    func updateCard(for currentID: UUID) {
        guard let index = cardItems.firstIndex(where: { $0.id == currentCardID?.uuidString }) else { return }
        self.cardItems[index] = CodableCardItem(id: currentID.uuidString,
                                                title_: self.title,
                                                subtitle_: self.subtitle.isEmpty ? nil : self.subtitle,
                                                image: self.detailImage,
                                                actionText_: self.actionText.isEmpty ? nil : self.actionText,
                                                actionContentURL_: URL(string: self.actionContentText),
                                                icon_: self.actionContentText.isEmpty ? nil : "link",
                                                position_: self.cardItems[index].position_)

        self.onSceneEdit(.updated(card: self.cardItems[index]))
    }

    func deleteCard(for currentID: UUID) {
        guard let cardToDelete = cardItems.first(where: { $0.id == currentID.uuidString }) else { return }

        self.cardItems.removeAll(where: { $0.id == cardToDelete.id })
        self.onSceneEdit(.deleted(card: cardToDelete))
    }
}

private struct CardDetailsView: View {
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var detailImage: CardImage?
    @Binding var actionText: String
    @Binding var actionContentText: String
    @Binding var actionButtonToggle: Bool
    @Binding var coverImageToggle: Bool

    @State private var actionSheetPresented = false
    @State private var pickerPresented = false
    @State private var pickerSource: ImagePickerSource = .photoLibrary

    @State private var pickedUIImage: UIImage? = nil

    var isUpdate: Bool
    var editCardAction: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Card Details", bundle: .fioriAR)
                    .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.secondaryLabel, background: .lightConstant))
                    .padding(16)
                Spacer()
            }

            Divider()

            ScrollView {
                ZStack {
                    VStack(spacing: 14) {
                        TextDetail(textField: $title, titleText: "Title *".localizedString)

                        TextDetail(textField: $subtitle, titleText: "Subtitle".localizedString)

                        TextDetail(textField: $actionContentText, toggle: $actionButtonToggle, titleText: "Content".localizedString, placeholder: "URL".localizedString)
                        
                        ToggleDetail(titleText: "Action Button".localizedString, placeholder: "Label".localizedString, textField: $actionText, isOn: $actionButtonToggle)
                            .zIndex(1)

                        CoverImageDetail(titleText: "Custom Cover Image".localizedString,
                                         isOn: $coverImageToggle,
                                         presentActionSheet: $actionSheetPresented,
                                         detailImage: $detailImage)

                        Button(action: {
                            editCardAction?()
                        }, label: {
                            Text(isUpdate ? "Update".localizedString : "Create".localizedString)
                                .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                                .foregroundColor(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
                                .frame(width: 343, height: 40)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.preferredColor(.tintColor, background: .lightConstant).opacity(title.isEmpty ? 0.5 : 1))
                                )
                                .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 4, y: 2)
                                .shadow(color: Color.preferredColor(.tintColor, background: .lightConstant).opacity(0.16), radius: 2)
                        })
                            .disabled(title.isEmpty)
                            .padding(.bottom, 54)
                    }
                    .padding(.top, 9.5)
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.preferredColor(.secondaryGroupedBackground, background: .lightConstant))
        .adaptsToKeyboard()
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
        .actionSheet(isPresented: $actionSheetPresented) {
            ActionSheet(title: Text("Choose an Option", bundle: .fioriAR),
                        message: nil,
                        buttons: [.default(Text("Camera", bundle: .fioriAR), action: {
                            pickerSource = .camera
                            pickerPresented.toggle()
                        }), .default(Text("Photos", bundle: .fioriAR), action: {
                            pickerSource = .photoLibrary
                            pickerPresented.toggle()
                        }), .cancel()])
        }
        .fullScreenCover(isPresented: $pickerPresented) {
            PickerSelectionView(uiImage: $pickedUIImage, imageSource: pickerSource)
                .edgesIgnoringSafeArea(.all)
        }
        .onChange(of: pickedUIImage) { newValue in
            guard let uiImage = newValue, let imageData = uiImage.pngData() else { return }
            if self.detailImage == nil {
                self.detailImage = CardImage(data: imageData)
            } else {
                self.detailImage?.data = imageData
            }
        }
    }
}

struct CardPreview: View {
    @Environment(\.openURL) var openURL

    @Binding var detailImage: Data?
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var actionText: String
    @Binding var actionContentText: String
    @Binding var icon: String?
    @Binding var hasButton: Bool

    init(detailImage: Binding<Data?>,
         title: Binding<String>,
         subtitle: Binding<String>,
         actionText: Binding<String>,
         actionContentText: Binding<String>,
         icon: Binding<String?>,
         hasButton: Binding<Bool>)
    {
        _detailImage = detailImage
        _title = title
        _subtitle = subtitle
        _actionText = actionText
        _actionContentText = actionContentText
        _icon = icon
        _hasButton = hasButton
    }

    init<CardItem>(cardItem: CardItem?) where CardItem: CardItemModel {
        _detailImage = .constant(cardItem?.detailImage_)
        _title = .constant(cardItem?.title_ ?? "")
        _subtitle = .constant(cardItem?.subtitle_ ?? "")
        _actionText = .constant(cardItem?.actionText_ ?? "")
        _actionContentText = .constant(cardItem?.actionContentURL_?.absoluteString ?? "")
        _icon = .constant(cardItem?.icon_)
        _hasButton = .constant(cardItem?.actionText_ != nil)
    }

    var body: some View {
        VStack(spacing: 10) {
            VStack {
                if let data = detailImage, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                } else {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 30))
                            .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                    } else {
                        Image(systemName: "info")
                            .font(.system(size: 30))
                            .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                    }
                }
            }
            .frame(width: 214, height: 93)
            .background(Color.preferredColor(.tertiaryFill, background: .lightConstant))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.top, 8)

            VStack(spacing: 4) {
                Text(title)
                    .font(.fiori(forTextStyle: .headline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 198, alignment: .leading)

                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.fiori(forTextStyle: .subheadline))
                        .foregroundColor(Color.preferredColor(.secondaryLabel, background: .lightConstant))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 198, alignment: .leading)
                }
            }
            .padding(.bottom, 5)

            Button(action: {
                if let linkURL = URL(string: actionContentText) {
                    openURL(linkURL)
                }
            }, label: {
                Text(actionText)
            })
                .font(.system(size: 18))
                .lineLimit(1)
                .foregroundColor(Color.preferredColor(.tintColor, background: .lightConstant))
                .frame(width: 198, height: hasButton && !actionText.isEmpty ? 44 : 0)
        }
        .frame(width: 230)
        .background(Color.preferredColor(.primaryBackground, background: .lightConstant))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
    }
}

struct TextDetail: View {
    @Binding var textField: String
    @Binding var toggle: Bool

    var titleText: String
    var placeholder: String?
    var fontWeight: Font.Weight

    internal init(textField: Binding<String>, toggle: Binding<Bool> = .constant(true), titleText: String, placeholder: String? = nil, fontWeight: Font.Weight = .bold) {
        _textField = textField
        _toggle = toggle
        self.titleText = titleText
        self.placeholder = placeholder
        self.fontWeight = fontWeight
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleText)
                .font(Font.fiori(forTextStyle: .subheadline).weight(fontWeight))
                .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
            FioriNextTextField(text: $textField, placeHolder: placeholder ?? titleText)
                .onChange(of: toggle) { newValue in
                    if !newValue {
                        textField = ""
                    }
                }
        }
    }
}

private struct ToggleDetail: View {
    var titleText: String
    var placeholder: String? = nil

    @Binding var textField: String
    @Binding var isOn: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isOn) {
                Text(titleText)
                    .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.preferredColor(.tintColor, background: .lightConstant)))
            .onChange(of: isOn) { newValue in
                if !newValue {
                    textField = ""
                }
            }

            FioriNextTextField(text: $textField, placeHolder: placeholder ?? titleText)
                .onChange(of: textField) { newValue in
                    isOn = newValue.isEmpty ? false : true
                }
        }
    }
}

private struct CoverImageDetail: View {
    var titleText: String = ""

    @Binding var isOn: Bool
    @Binding var presentActionSheet: Bool
    @Binding var detailImage: CardImage?

    var body: some View {
        VStack(spacing: 8) {
            Toggle(isOn: $isOn) {
                Text(titleText)
                    .font(.fiori(forTextStyle: .subheadline).weight(.bold))
                    .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.preferredColor(.tintColor, background: .lightConstant)))
            .padding(.vertical, 5)
            .onChange(of: isOn) { newValue in
                if newValue {
                    presentActionSheet.toggle()
                } else {
                    detailImage?.data = nil
                }
            }
            .zIndex(0)

            ImageSelectionView(detailImage: detailImage, imageHeight: 145)
                .zIndex(-1)
                .onChange(of: detailImage) { newValue in
                    isOn = newValue?.data == nil ? false : true
                }
                .onTapGesture {
                    presentActionSheet.toggle()
                }
        }
    }
}

struct ImageSelectionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var detailImage: CardImage?
    var imageHeight: CGFloat
    var contentMode: ContentMode = .fill

    var body: some View {
        VStack {
            if let data = detailImage?.data, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(height: imageHeight)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .foregroundColor(Color.preferredColor(.tertiaryFill, background: .lightConstant))
                    .font(.system(size: 40))
            }
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 311 : .infinity, minHeight: imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.preferredColor(.separatorOpaque, background: .lightConstant), lineWidth: 0.33)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.preferredColor(.secondaryFill)))
        )
    }
}

private struct AdaptiveStack<Content>: View where Content: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass

    var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        if verticalSizeClass == .compact {
            HStack {
                content
            }
        } else {
            VStack {
                content
            }
        }
    }
}
