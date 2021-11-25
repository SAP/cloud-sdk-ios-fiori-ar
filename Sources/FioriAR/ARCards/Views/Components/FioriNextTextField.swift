//
//  FioriNextTextField.swift
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
            .font(.fiori(forTextStyle: .body))
            .foregroundColor(Color.preferredColor(.primaryLabel, background: .lightConstant))
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
                        .strokeBorder(Color.preferredColor(editingText ? .tintColor : .separatorOpaque, background: .lightConstant), lineWidth: editingText ? 2 : text.isEmpty ? 0.33 : 1)
                        .background(Color.preferredColor(editingText ? .primaryFill : .secondaryFill, background: .lightConstant).cornerRadius(10))
                    HStack {
                        Text(text.isEmpty ? placeholder : "")
                            .font(.fiori(forTextStyle: .body).italic())
                            .foregroundColor(Color.preferredColor(.tertiaryLabel, background: .lightConstant))
                            .padding(.leading, 12)
                        Spacer()
                    }
                }
            )
    }
}
