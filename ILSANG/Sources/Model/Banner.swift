//
//  Banner.swift
//  ILSANG
//
//  Created by Lee Jinhee on 1/23/25.
//

import UIKit

struct Banner: Hashable {
    let id: Int
    let title: String
    let description: String
    let navTitle: String?
    let imageId: String
    var image: UIImage?
    
    init(id: Int, title: String, description: String, navTitle: String, imageId: String, image: UIImage) {
        self.id = id
        self.title = title
        self.description = description
        self.navTitle = navTitle
        self.imageId = imageId
        self.image = image
    }
    
    init(from banner: BannerEntity) {
        self.id = banner.id
        self.title = banner.title
        self.description = banner.description
        self.navTitle = banner.navTitle
        self.imageId = banner.image.imageId
        self.image = nil
    }
}

struct BannerEntity: Decodable {
    let id: Int
    let title: String
    let description: String
    let navTitle: String?
    let image: BannerImage
    let activeYn: String
    
    struct BannerImage: Decodable {
        let imageId: String
        let location: String
    }
}
