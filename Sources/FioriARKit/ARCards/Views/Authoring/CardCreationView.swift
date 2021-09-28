//
//  CardCreationView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import SwiftUI

public enum CardEditing {
    case created(card: DecodableCardItem)
    case updated(card: DecodableCardItem)
    case deleted(card: DecodableCardItem)
}

struct CardCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onCardEdit) var onCardEdit
    
    @Binding var cardItems: [DecodableCardItem]
    @Binding var attachmentModels: [AttachmentItemModel]
    @Binding var currentCardID: UUID?
    
    @State var detailImage: Image?
    @State var title: String
    @State var subtitle: String
    @State var actionText: String
    @State var actionContentText: String
    @State var icon: Image?
    
    @State var hasButton = false
    @State var hasCoverImage = false
    
    init(cardItems: Binding<[DecodableCardItem]>, attachmentModels: Binding<[AttachmentItemModel]>, currentCardID: Binding<UUID?>) {
        self._cardItems = cardItems
        self._attachmentModels = attachmentModels
        self._currentCardID = currentCardID
        
        let currentCard = cardItems.wrappedValue.first(where: { UUID(uuidString: $0.id) == currentCardID.wrappedValue })
        
        self._detailImage = State(initialValue: currentCard?.detailImage_)
        self._title = State(initialValue: currentCard?.title_ ?? "")
        self._subtitle = State(initialValue: currentCard?.descriptionText_ ?? "")
        self._actionText = State(initialValue: currentCard?.actionText_ ?? "")
        self._actionContentText = State(initialValue: "")
        
        self._hasButton = State(initialValue: currentCard?.actionText_ == nil ? false : true)
        self._hasCoverImage = State(initialValue: currentCard?.detailImage_ == nil ? false : true)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            TitleBarView(onLeftAction: {
                presentationMode.wrappedValue.dismiss()
            }, onRightAction: {
                if let currentID = currentCardID {
                    deleteCard(for: currentID)
                }
                presentationMode.wrappedValue.dismiss()
            },
            title: "Title",
            leftBarLabel: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(Color.fnBlue)
                
            }, rightBarLabel: {
                if let _ = currentCardID {
                    Image(systemName: "trash")
                        .font(.system(size: 22))
                        .foregroundColor(.gray)
                }
            })
                .background(Color.fioriNextBackgroundGrey)
            
            ZStack {
                Color
                    .fioriNextBackgroundGrey
                
                CardPreview(detailImage: $detailImage, title: $title, descriptionText: $subtitle, actionText: $actionText, icon: $icon)
                    .offset(y: -10)
            }
            .frame(height: 246)

            CardDetailsView(cardItems: $cardItems,
                            detailImage: $detailImage,
                            title: $title,
                            subtitle: $subtitle,
                            actionText: $actionText,
                            actionContentText: $actionContentText,
                            actionButtonToggle: $hasButton,
                            coverImageToggle: $hasCoverImage,
                            toggleActionSheet: {
                                if let currentID = currentCardID {
                                    updateCard(for: currentID)
                                } else {
                                    createCard()
                                }
                                presentationMode.wrappedValue.dismiss()
                            })
                .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
        }
        .onDisappear {
            currentCardID = nil
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.vertical)
        .background(Color.fioriNextBackgroundGrey)
    }
    
    func createCard() {
        let newCard = DecodableCardItem(id: UUID().uuidString, title_: self.title, descriptionText_: self.subtitle, detailImage_: self.detailImage, actionText_: self.actionText, icon_: nil)
        self.cardItems.append(newCard)
        
        self.onCardEdit(.created(card: newCard))
    }
    
    func updateCard(for currentID: UUID) {
        guard let index = cardItems.firstIndex(where: { UUID(uuidString: $0.id) == currentCardID }) else { return }
        self.cardItems[index] = DecodableCardItem(id: currentID.uuidString,
                                                  title_: self.title,
                                                  descriptionText_: self.subtitle,
                                                  detailImage_: self.detailImage,
                                                  actionText_: self.actionText,
                                                  icon_: nil)
        
        self.onCardEdit(.updated(card: self.cardItems[index]))
    }
    
    func deleteCard(for currentID: UUID) {
        guard let cardToDelete = cardItems.first(where: { UUID(uuidString: $0.id) == currentID }) else { return }
        
        self.cardItems.removeAll(where: { $0.id == cardToDelete.id })
        self.attachmentModels.removeAll(where: { $0.id == currentID })
        
        self.onCardEdit(.deleted(card: cardToDelete))
    }
}

private struct CardDetailsView: View {
    @Binding var cardItems: [DecodableCardItem]
    
    @Binding var detailImage: Image?
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var actionText: String
    @Binding var actionContentText: String
    
    @Binding var actionButtonToggle: Bool
    @Binding var coverImageToggle: Bool
    
    @State var actionSheetPresented = false
    var toggleActionSheet: (() -> Void)?
    
    @State var pickerPresented = false
    @State var pickerSource: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Card Details")
                .font(.system(size: 15))
                .bold()
                .padding(16)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .center, spacing: 15) {
                    TextDetail(textField: $title, titleText: "Title")

                    TextDetail(textField: $subtitle, titleText: "Subtitle")
                    
                    TextDetail(textField: $actionContentText, titleText: "Content", placeholder: "URL")
                    
                    ToggleDetail(titleText: "Action Button (Optional)", textField: $actionText, isOn: $actionButtonToggle)
                    
                    CoverImageDetail(titleText: "Custom Cover Image (Optional)", isOn: $coverImageToggle, presentActionSheet: $actionSheetPresented, detailImage: $detailImage)
                    
                    Button(action: {
                        toggleActionSheet?()
                    }, label: {
                        Text("Create")
                            .font(.system(size: 15))
                            .bold()
                            .frame(width: 343, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.fnBlue)
                            )
                    })
                        .padding(.bottom, 54)
                }
                .padding(.top, 9.5)
                .padding(.horizontal, 16)
            }
        }
        .background(Color.white)
        .cornerRadius(16)
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
            CameraView(takenImage: $detailImage, fileName: .constant(nil), sourceType: pickerSource)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

private struct CardPreview: View {
    @Binding var detailImage: Image?
    @Binding var title: String
    @Binding var descriptionText: String
    @Binding var actionText: String
    @Binding var icon: Image?
    
    var body: some View {
        VStack(spacing: 10) {
            VStack {
                if let detailImage = detailImage {
                    detailImage
                        .resizable()
                        .scaledToFill()
                    
                } else {
                    (icon ?? Image(systemName: "info"))
                        .font(.system(size: 37))
                        .foregroundColor(Color.preferredColor(.quarternaryLabel, background: .lightConstant))
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
                
                if !descriptionText.isEmpty {
                    Text(descriptionText)
                        .font(.subheadline)
                        .foregroundColor(Color.preferredColor(.secondaryLabel, background: .lightConstant))
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(width: 198, alignment: .leading)
                }
            }
            .padding(.bottom, 5)
            
            Button(action: {}, label: {
                Text(actionText)
            })
                .font(.system(size: 18))
                .lineLimit(1)
                .foregroundColor(Color.preferredColor(.tintColor, background: .lightConstant))
                .frame(width: 198, height: actionText.isEmpty ? 0 : 44)
        }
        .frame(width: 230)
        .background(Color.preferredColor(.primaryBackground, background: .lightConstant))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.15), radius: 4, y: 2)
    }
}

private struct TextDetail: View {
    @Binding var textField: String
    
    var titleText: String
    var placeholder: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 9.5) {
            Text(titleText)
                .font(.system(size: 15))
            FioriNextTextField(text: $textField, placeHolder: placeholder ?? titleText)
        }
    }
}

private struct ContentDetail: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 9.5) {
            Text("Content")
                .font(.system(size: 15))
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
                .frame(height: 66)
                .overlay(
                    Text("Add Content")
                        .foregroundColor(Color.fnBlue)
                        .font(.system(size: 15))
                        .bold()
                )
                .onTapGesture {}
        }
    }
}

private struct ToggleDetail: View {
    var titleText: String
    @Binding var textField: String
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9.5) {
            Toggle(titleText, isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.fnBlue))
                .font(.system(size: 15))
            
            FioriNextTextField(text: $textField, placeHolder: titleText)
        }
    }
}

private struct CoverImageDetail: View {
    var titleText: String = ""
    
    @Binding var isOn: Bool
    @Binding var presentActionSheet: Bool
    @Binding var detailImage: Image?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9.5) {
            Toggle(titleText, isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.fnBlue))
                .padding(.vertical, 5)

            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
                .overlay(
                    Group {
                        if let detailImage = detailImage {
                            detailImage
                                .resizable()
                                .scaledToFill()
                        } else {
                            Image(systemName: "photo")
                                .foregroundColor(Color.imageGrey)
                                .font(.system(size: 40))
                        }
                    }
                )
                .frame(height: 145)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .contentShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture {
                    presentActionSheet.toggle()
                }
        }
    }
}
