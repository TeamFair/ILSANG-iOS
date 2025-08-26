//
//  BannerResponse+Mapping.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/26/25.
//

import Foundation

extension BannerResponse: DomainConvertible {
    func toDomain() -> Banner {
        Banner(
            id: id,
            title: title,
            navigationTitle: navigationTitle,
            imageId: bannerImageId,
            description: description
        )
    }
}
