//
//  QuestImageWithTagView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 12/1/24.
//

import SwiftUI

struct QuestImageWithTagView: View {
    let image: UIImage?
    let imageSize: CGSize
    let tagConfig: TagConfig?

    var body: some View {
        Image(uiImage: image ?? .logo)
            .resizable()
            .scaledToFill()
            .frame(width: imageSize.width, height: imageSize.height)
            .background(Color.badgeBlue)
            .clipShape(Circle())
            .overlay(alignment: .topTrailing) {
                if let tagConfig {
                    TagView(title: tagConfig.title, image: tagConfig.image, tagStyle: tagConfig.style)
                        .position(x: tagConfig.offset.x, y: tagConfig.offset.y)
                }
            }
    }
}
