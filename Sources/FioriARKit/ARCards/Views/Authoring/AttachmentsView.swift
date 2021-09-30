//
//  AttachmentsView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import SwiftUI

struct AttachementsView: View {
    @Binding var attachmentItemModels: [AttachmentItemModel]
    var onAddAttachment: (() -> Void)?
    var onSelectAttachment: ((AttachmentItemModel) -> Void)?
    
    init(attachmentItemModels: Binding<[AttachmentItemModel]>, onAddAttachment: (() -> Void)? = nil, onSelectAttachment: ((AttachmentItemModel) -> Void)? = nil) {
        self._attachmentItemModels = attachmentItemModels
        self.onAddAttachment = onAddAttachment
        self.onSelectAttachment = onSelectAttachment
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
                LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 110), alignment: .top), count: 1), spacing: 8) {
                    ForEach(attachmentItemModels) { attachementItemModel in
                        if attachementItemModel.title == AttachmentItemModel.addAttachment {
                            AddAttachmentView()
                                .onTapGesture {
                                    onAddAttachment?()
                                }
                        } else {
                            AttachmentCardView(item: attachementItemModel)
                                .onTapGesture {
                                    onSelectAttachment?(attachementItemModel)
                                }
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.horizontal, 16)
        .onAppear {
            if !attachmentItemModels.contains(where: { $0.title == AttachmentItemModel.addAttachment }) {
                attachmentItemModels.insert(AttachmentItemModel(title: AttachmentItemModel.addAttachment), at: 0)
            }
        }
    }
}

struct AddAttachmentView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
            .overlay(Image(systemName: "plus").font(.system(size: 22)).foregroundColor(.blue))
            .frame(width: 110, height: 110)
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
            .frame(width: 110, height: 110)
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
                    if let subtitle = item.subtitle {
                        Text(subtitle)
                            .foregroundColor(.gray)
                    }
                    if let info = item.info {
                        Text(info)
                            .foregroundColor(.gray)
                    }
                }
                .lineLimit(1)
                .font(.system(size: 11))
                .foregroundColor(Color.black)
                .padding(.horizontal, 3)
                Spacer()
            }
            Spacer()
        }
    }
}
