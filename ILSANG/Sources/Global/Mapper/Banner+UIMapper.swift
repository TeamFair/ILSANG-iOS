//
//  Banner+UIMapper.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 8/26/25.
//

import Foundation

extension Banner {
    func toBanner() -> BannerViewModelItem {
        BannerViewModelItem(
            id: id,
            title: title,
            navigationTitle: navigationTitle,
            imageId: imageId,
            description: description,
            image: nil
        )
    }
}
