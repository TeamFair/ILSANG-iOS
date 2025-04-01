//
//  QuestImageWithTagView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/1/24.
//

import SwiftUI

struct QuestImageWithTagView: View {
    let image: UIImage?
    let tagTitle: String
    let tagImage: ImageResource?
    let tagStyle: TagView.TagStyle
    let tagOffset: (x: CGFloat, y: CGFloat)
    let imageSize: CGSize
    
    var body: some View {
        Image(uiImage: image ?? .logo)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize.width, height: imageSize.height)
            .background(Color.badgeBlue)
            .clipShape(Circle())
            .overlay(alignment: .topTrailing) {
                TagView(title: tagTitle, image: tagImage, tagStyle: tagStyle)
                    .position(x: tagOffset.x, y: tagOffset.y)
            }
    }
}
