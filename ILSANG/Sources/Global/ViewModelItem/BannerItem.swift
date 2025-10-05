//
//  BannerItem.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/26/25.
//

import UIKit

@Observable
class BannerItem: Hashable, Identifiable {
    static func == (lhs: BannerItem, rhs: BannerItem) -> Bool {
        lhs.id == rhs.id && lhs.image == rhs.image
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(image)
    }
    
    let id: Int
    let title: String
    let navigationTitle: String
    let imageId: String
    let description: String
    var image: UIImage?
 
    init(id: Int, title: String, navigationTitle: String, imageId: String, description: String, image: UIImage?) {
        self.id = id
        self.title = title
        self.navigationTitle = navigationTitle
        self.imageId = imageId
        self.description = description
        self.image = image
    }
}
