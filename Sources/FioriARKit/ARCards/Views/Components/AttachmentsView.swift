//
//  AttachmentsView.swift
//
//
//  Created by O'Brien, Patrick on 9/16/21.
//

import SwiftUI

public struct AttachmentsItemModel: Identifiable {
    public var id = UUID()
    public var title: String = ""
    public var subtitle: String?
    public var info: String?
    public var image: Image?
    public var icon: Image?
}

struct AttachmentsView: View {
    @Binding var attachmentsItemModels: [AttachmentsItemModel]
    var label: String
    var onAddAttachment: (() -> Void)?
    var onSelectAttachment: ((AttachmentsItemModel) -> Void)?
    
    init(label: String, attachmentsItemModels: Binding<[AttachmentsItemModel]>, onAddAttachment: (() -> Void)? = nil, onSelectAttachment: ((AttachmentsItemModel) -> Void)? = nil) {
        self.label = label
        self._attachmentsItemModels = attachmentsItemModels
        self.onAddAttachment = onAddAttachment
        self.onSelectAttachment = onSelectAttachment
    }

    public var body: some View {
        VStack(spacing: 11) {
            HStack {
                Text(label)
                    .foregroundColor(Color.black)
                    .bold()
                    .font(.system(size: 15))
                    +
                    Text(" (\(attachmentsItemModels.count))")
                    .foregroundColor(Color.black)
                    .bold()
                    .font(.system(size: 15))
                Spacer()
            }
            
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(columns: Array(repeating: GridItem(.adaptive(minimum: 110), alignment: .top), count: 1), spacing: 8) {
                    ForEach(-1 ..< attachmentsItemModels.count, id: \.self) { index in
                        if index == -1 {
                            AddAttachmentView
                                .onTapGesture {
                                    onAddAttachment?()
                                }
                        } else {
                            AttachmentCardView(item: attachmentsItemModels[index])
                                .onTapGesture {
                                    onSelectAttachment?(attachmentsItemModels[index])
                                }
                        }
                    }
                }
                .padding(.top, 5)
            }
        }
        .padding(.horizontal, 16)
    }
    
    private var AddAttachmentView: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round, dash: [7]))
            .overlay(Image(systemName: "plus").font(.system(size: 22)).foregroundColor(Color.fioriNextTint))
            .frame(width: 110, height: 110)
    }
}

private struct AttachmentCardView: View {
    var item: AttachmentsItemModel
    
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
                Spacer()
            }
            Spacer()
        }
        .frame(width: 110)
    }
}
