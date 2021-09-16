//
//  AttachmentsView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import SwiftUI

struct AttachementsView: View {
    @Binding var attachmentItemModels: [AttachmentItemModel]
    
    @State private var containerSize: CGSize = .zero
    @State private var screenWidth = Int(UIScreen.main.bounds.width)
    
    var onAddAttachment: (() -> Void)?
    
    init(attachmentItemModels: Binding<[AttachmentItemModel]>) {
        self._attachmentItemModels = attachmentItemModels
    }
    
    var addAttachmentView: some View {
        VStack {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray,
                        style: StrokeStyle(lineWidth: 1,
                                           lineCap: .round,
                                           lineJoin: .round,
                                           dash: [7]))
                .overlay(Image(systemName: "plus").font(.system(size: 22)).foregroundColor(.blue))
                .frame(width: 110, height: 110)
            Spacer()
        }
    }
    
    public var body: some View {
        VStack(spacing: 11) {
            HStack {
                Text("Annotation Cards (\(attachmentItemModels.count - 1))")
                    .font(.system(size: 15))
                    .bold()
                Spacer()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 110)), count: 1), spacing: 5) {
                    ForEach(attachmentItemModels) { attachementItemModel in
                        
                        if attachementItemModel.title == "AddAttachment" {
                            addAttachmentView
                                .onTapGesture {
                                    onAddAttachment?()
                                    attachmentItemModels.append(AttachmentItemModel(title: "filename.pdf", subtitle: "file size", info: "optional info"))
                                }
                        } else {
                            AttachmentCardView(item: attachementItemModel)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .onAppear {
            if !attachmentItemModels.contains(where: { $0.title == AttachmentItemModel.addAttachment }) {
                attachmentItemModels.insert(AttachmentItemModel(title: AttachmentItemModel.addAttachment), at: 0)
            }
        }
    }
}

struct AttachmentCardView: View {
    var item: AttachmentItemModel
    
    var body: some View {
        VStack {
            ZStack {
                (item.icon ?? Image(systemName: "info"))
                    .font(.system(size: 28))
                    .foregroundColor(.gray)
                    
                if let image = item.image {
                    image
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(width: 107.32, height: 107.32)
            .cornerRadius(8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
            HStack {
                VStack(alignment: .leading) {
                    Text(item.title)
                        .bold()
                        .lineLimit(2)
                        .truncationMode(.middle)
                    Text(item.subtitle)
                    Text(item.info)
                }
                .lineLimit(1)
                .font(.system(size: 11))
                Spacer()
            }
            Spacer()
        }
        .padding(.bottom, 5)
    }
}
