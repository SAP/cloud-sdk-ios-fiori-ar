//
//  CardCreationView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import Combine
import SwiftUI

public enum SceneEditing {
    case created(card: CodableCardItem)
    case updated(card: CodableCardItem)
    case deleted(card: CodableCardItem)
    case published(sceneID: Int)
}

struct CardFormView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onSceneEdit) var onSceneEdit
    
    @Binding var cardItems: [CodableCardItem]
    @Binding var attachmentModels: [AttachmentUIMetadata]
    @Binding var currentCardID: UUID?
    
    @State var detailImage: Data?
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
         onDismiss: (() -> Void)?)
    {
        self._cardItems = cardItems
        self._attachmentModels = attachmentModels
        self._currentCardID = currentCardID
        
        let currentCard = cardItems.wrappedValue.first(where: { $0.id == currentCardID.wrappedValue?.uuidString })
        
        self._detailImage = State(initialValue: currentCard?.detailImage_)
        self._title = State(initialValue: currentCard?.title_ ?? "")
        self._subtitle = State(initialValue: currentCard?.subtitle_ ?? "")
        self._actionText = State(initialValue: currentCard?.actionText_ ?? "")
        self._actionContentText = State(initialValue: currentCard?.actionContentURL_?.absoluteString ?? "")
        self._icon = State(initialValue: currentCard?.icon_)
        
        self._hasButton = State(initialValue: currentCard?.actionText_ == nil ? false : true)
        self._hasCoverImage = State(initialValue: currentCard?.detailImage_ == nil ? false : true)
        
        self.isUpdate = currentCardID.wrappedValue == nil ? false : true
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBarView(title: isUpdate ? title : "New Annotation",
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
                                 .foregroundColor(.black)
                         },
                         rightBarLabel: {
                             if let _ = currentCardID {
                                 Image(systemName: "trash")
                                     .font(.system(size: 22))
                                     .foregroundColor(.black)
                             }
                         })
                .background(Color.fioriNextPrimaryBackground)
            
            AdaptiveStack {
                ZStack {
                    Color
                        .fioriNextPrimaryBackground
                    CardPreview(detailImage: $detailImage,
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
            .background(Color.fioriNextPrimaryBackground)
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
        .edgesIgnoringSafeArea(verticalSizeClass == .compact ? [.horizontal, .bottom] : .vertical)
        .ignoresSafeArea(.keyboard)
    }
    
    func createCard() {
        let newCard = CodableCardItem(id: UUID().uuidString,
                                      title_: self.title,
                                      subtitle_: self.subtitle.isEmpty ? nil : self.subtitle,
                                      detailImage_: self.detailImage,
                                      actionText_: self.actionText.isEmpty ? nil : self.actionText,
                                      actionContentURL_: URL(string: self.actionContentText),
                                      icon_: self.actionContentText.isEmpty ? nil : "link")
        
        self.cardItems.append(newCard)
        self.onSceneEdit(.created(card: newCard))
    }
    
    func updateCard(for currentID: UUID) {
        guard let index = cardItems.firstIndex(where: { $0.id == currentCardID?.uuidString }) else { return }
        self.cardItems[index] = CodableCardItem(id: currentID.uuidString,
                                                title_: self.title,
                                                subtitle_: self.subtitle.isEmpty ? nil : self.subtitle,
                                                detailImage_: self.detailImage,
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
    @Binding var detailImage: Data?
    @Binding var actionText: String
    @Binding var actionContentText: String
    @Binding var actionButtonToggle: Bool
    @Binding var coverImageToggle: Bool
    
    @State var actionSheetPresented = false
    @State var pickerPresented = false
    @State var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    var isUpdate: Bool
    var editCardAction: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Card Details")
                    .font(.system(size: 15, weight: .bold))
                    .padding(16)
                Spacer()
            }
            
            Divider()
            
            ScrollView {
                ZStack {
                    VStack(spacing: 14) {
                        TextDetail(textField: $title, titleText: "*Title")
                            .foregroundColor(Color.black)
                        
                        TextDetail(textField: $subtitle, titleText: "Subtitle (Optional)")
                            .foregroundColor(Color.black)
                        
                        ToggleDetail(titleText: "Action Button (Optional)", textField: $actionText, isOn: $actionButtonToggle)
                            .foregroundColor(Color.black)
                        
                        TextDetail(textField: $actionContentText, toggle: $actionButtonToggle, titleText: "Content (Optional)", placeholder: "URL")
                            .foregroundColor(Color.black)
                            .zIndex(1)
                        
                        CoverImageDetail(titleText: "Custom Cover Image (Optional)",
                                         isOn: $coverImageToggle,
                                         presentActionSheet: $actionSheetPresented,
                                         detailImage: $detailImage)
                        
                        Button(action: {
                            editCardAction?()
                        }, label: {
                            Text(isUpdate ? "Update" : "Create")
                                .font(.system(size: 15, weight: .bold))
                                .frame(width: 343, height: 40)
                                .foregroundColor(.white)
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(title.isEmpty ? Color.fioriNextTint.opacity(0.5) : Color.fioriNextTint)
                                )
                                .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 4, y: 2)
                                .shadow(color: Color.fioriNextTint.opacity(0.16), radius: 2)
                        })
                            .disabled(title.isEmpty)
                            .padding(.bottom, 54)
                    }
                    .padding(.top, 9.5)
                    .padding(.horizontal, 16)
                }
            }
        }
        .background(Color.white)
        .adaptsToKeyboard()
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
        .actionSheet(isPresented: $actionSheetPresented) {
            ActionSheet(title: Text("Choose an option..."),
                        message: Text("Selection for Card Cover Image"),
                        buttons: [.default(Text("Camera"), action: {
                            pickerSource = .camera
                            pickerPresented.toggle()
                        }), .default(Text("Photos"), action: {
                            pickerSource = .photoLibrary
                            pickerPresented.toggle()
                        }), .cancel()])
        }
        .fullScreenCover(isPresented: $pickerPresented) {
            ImagePickerView(imageData: $detailImage, sourceType: pickerSource)
                .edgesIgnoringSafeArea(.all)
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
                            .foregroundColor(Color.preferredColor(.quarternaryLabel, background: .lightConstant))
                    } else {
                        Image(systemName: "info")
                            .font(.system(size: 30))
                            .foregroundColor(Color.preferredColor(.quarternaryLabel, background: .lightConstant))
                    }
                }
            }
            .frame(width: 214, height: 93)
            .background(Color.preferredColor(.tertiaryFill))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.top, 8)
            
            VStack(spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.preferredColor(.header, background: .lightConstant))
                    .lineLimit(2)
                    .truncationMode(.tail)
                    .frame(width: 198, alignment: .leading)
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.subheadline)
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
    
    internal init(textField: Binding<String>, toggle: Binding<Bool> = .constant(true), titleText: String, placeholder: String? = nil) {
        _textField = textField
        _toggle = toggle
        self.titleText = titleText
        self.placeholder = placeholder
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(titleText)
                .font(.system(size: 15, weight: .bold))
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
    
    @Binding var textField: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: $isOn) {
                Text(titleText)
                    .foregroundColor(Color.black)
                    .font(.system(size: 15, weight: .bold))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.fioriNextTint))
            .onChange(of: isOn) { newValue in
                if !newValue {
                    textField = ""
                }
            }
            
            FioriNextTextField(text: $textField, placeHolder: titleText)
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
    @Binding var detailImage: Data?
    
    var body: some View {
        VStack(spacing: 8) {
            Toggle(isOn: $isOn) {
                Text(titleText)
                    .foregroundColor(Color.black)
                    .font(.system(size: 15, weight: .bold))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color.fioriNextTint))
            .padding(.vertical, 5)
            .onChange(of: isOn) { newValue in
                if newValue {
                    presentActionSheet.toggle()
                } else {
                    detailImage = nil
                }
            }
            .zIndex(0)
            
            ImageSelectionView(detailImage: detailImage, imageHeight: 145)
                .zIndex(-1)
                .onChange(of: detailImage) { newValue in
                    isOn = newValue == nil ? false : true
                }
                .onTapGesture {
                    presentActionSheet.toggle()
                }
        }
    }
}

struct ImageSelectionView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var detailImage: Data?
    var imageHeight: CGFloat
    var contentMode: ContentMode = .fill

    var body: some View {
        VStack {
            if let data = detailImage, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
                    .frame(height: imageHeight)
                    .clipped()
            } else {
                Image(systemName: "photo")
                    .foregroundColor(Color.fioriNextSecondaryFill.opacity(0.24))
                    .font(.system(size: 40))
            }
        }
        .frame(maxWidth: horizontalSizeClass == .regular ? 311 : .infinity, minHeight: imageHeight)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .contentShape(RoundedRectangle(cornerRadius: 10))
        .background(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(Color.fioriNextSecondaryFill.opacity(0.83), lineWidth: 0.33)
                .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.fioriNextSecondaryFill.opacity(0.06)))
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
            .padding(.horizontal, 40)
        } else {
            VStack {
                content
            }
        }
    }
}
