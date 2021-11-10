//
//  SwiftUIView.swift
//
//
//  Created by O'Brien, Patrick on 9/22/21.
//

import SwiftUI

struct FioriNextTextField: View {
    @Binding var text: String
    var placeHolder = ""
    
    @State private var editingText = false

    var body: some View {
        TextField("", text: $text, onEditingChanged: { editingText = $0 }, onCommit: {})
            .textFieldStyle(FioriNextTextFieldStyle(editingText: $editingText, placeholder: placeHolder, text: text))
            .foregroundColor(Color.black)
            .font(.system(size: 17))
    }
}

struct FioriNextTextFieldStyle: TextFieldStyle {
    @Binding var editingText: Bool
    
    var placeholder: String
    var text: String
    var isTyping: Bool = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.leading, 12)
            .frame(height: 46)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(editingText ? Color.fioriNextTint : Color.fioriNextSecondaryFill.opacity(0.83), lineWidth: editingText ? 2 : 0.33)
                        .background(Color.fioriNextPrimaryBackground.cornerRadius(10))
                    HStack {
                        Text(text.isEmpty ? placeholder : "")
                            .font(.system(size: 17))
                            .italic()
                            .foregroundColor(Color.fioriNextSecondaryFill.opacity(0.83))
                            .padding(.leading, 12)
                        Spacer()
                    }
                }
            )
    }
}
