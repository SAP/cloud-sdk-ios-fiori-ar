//
//  CardCreationView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import SwiftUI

struct CardCreationView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var cardItems: [DecodableCardItem]
    @Binding var currentCardID: UUID?
    
    @State var image: Image?
    @State var title: String
    @State var subtitle: String
    @State var actionText: String
    
    @State var hasButton = false
    @State var hasCoverImage = false
    
    init(cardItems: Binding<[DecodableCardItem]>, currentCardID: Binding<UUID?>) {
        self._cardItems = cardItems
        self._currentCardID = currentCardID
        
        let currentCard = cardItems.wrappedValue.first(where: { UUID(uuidString: $0.id) == currentCardID.wrappedValue })
        
        self._image = State(initialValue: currentCard?.detailImage_)
        self._title = State(initialValue: currentCard?.title_ ?? "")
        self._subtitle = State(initialValue: currentCard?.descriptionText_ ?? "")
        self._actionText = State(initialValue: currentCard?.actionText_ ?? "")
        
        self._hasButton = State(initialValue: currentCard?.actionText_ == nil ? false : true)
        self._hasCoverImage = State(initialValue: currentCard?.detailImage_ == nil ? false : true)
    }
    
    var body: some View {
        VStack {
            TitleBarView(onLeftAction: {
                presentationMode.wrappedValue.dismiss()
            }, onRightAction: {
                deleteCard()
            },
            title: "Title", leftBarLabel: {
                Image(systemName: "xmark")
                    .font(.system(size: 22))
                    .foregroundColor(Color.sapBlue)
                
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
                
                CardView<Text, Text, EmptyView, Text, DecodableCardItem>(
                    title: {
                        Text(title)
                    }, descriptionText: {
                        Text(subtitle)
                    }, detailImage: {}, actionText: {
                        Text(actionText)
                    },
                    isSelected: hasButton,
                    id: "",
                    action: { _ in }
                )
            }
            .frame(height: 246)

            CardDetailsView(cardItems: $cardItems,
                            image: $image,
                            title: $title,
                            subtitle: $subtitle,
                            actionText: $actionText,
                            actionButtonToggle: $hasButton,
                            coverImageToggle: $hasCoverImage)
                .shadow(radius: 1)
            
            Spacer()
        }
        .navigationBarHidden(true)
        .navigationBarTitle("")
        .edgesIgnoringSafeArea(.vertical)
        .background(Color.fioriNextBackgroundGrey)
    }
    
    func deleteCard() {
        if let currentID = currentCardID {
            self.cardItems.removeAll(where: {
                UUID(uuidString: $0.id) == currentID
            })
            self.presentationMode.wrappedValue.dismiss()
        }
    }
}

private struct CardDetailsView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.onCardCreation) var onCardCreation
    
    @Binding var cardItems: [DecodableCardItem]
    
    @Binding var image: Image?
    @Binding var title: String
    @Binding var subtitle: String
    @Binding var actionText: String
    
    @Binding var actionButtonToggle: Bool
    @Binding var coverImageToggle: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Card Details")
                .font(.system(size: 15))
                .bold()
                .padding(16)
            
            Divider()
            
            ScrollView {
                VStack(alignment: .center, spacing: 15) {
                    TextDetail(titleText: "Title", textField: $title)

                    TextDetail(titleText: "Subtitle", textField: $subtitle)
                    
                    ContentDetail()
                    
                    ToggleDetail(titleText: "Action Button (Optional)", textField: $actionText, isOn: $actionButtonToggle)
                    
                    CoverImageDetail(titleText: "Custom Cover Image (Optional)", isOn: $coverImageToggle)
                    
                    Button(action: {
                        createCard()
                    }, label: {
                        Text("Create")
                            .font(.system(size: 15))
                            .bold()
                            .frame(width: 343, height: 40)
                            .foregroundColor(.white)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.sapBlue)
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
    }
    
    func createCard() {
        let createdCard = DecodableCardItem(id: UUID().uuidString, title_: self.title, descriptionText_: self.subtitle, detailImage_: nil, actionText_: nil, icon_: nil)
        self.cardItems.append(createdCard)
        self.presentationMode.wrappedValue.dismiss()
        self.onCardCreation?(createdCard)
    }
}

private struct TextDetail: View {
    var titleText: String
    @Binding var textField: String

    var body: some View {
        VStack(alignment: .leading, spacing: 9.5) {
            Text(titleText)
                .font(.system(size: 15))
            FioriNextTextField(text: $textField, placeHolder: titleText)
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
                        .foregroundColor(Color.sapBlue)
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
                .toggleStyle(SwitchToggleStyle(tint: Color.sapBlue))
                .font(.system(size: 15))
            
            FioriNextTextField(text: $textField, placeHolder: titleText)
        }
    }
}

private struct CoverImageDetail: View {
    var titleText: String = ""
    @Binding var isOn: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 9.5) {
            Toggle(titleText, isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: Color.sapBlue))
                .padding(.vertical, 5)
            
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
                .frame(height: 145)
                .overlay(
                    Image(systemName: "photo")
                        .foregroundColor(Color.imageGrey)
                        .font(.system(size: 40))
                )
        }
    }
}
