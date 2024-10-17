//
//  ImageCacheService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/17/24.
//

import UIKit

final class ImageCacheService {
    public static let shared = ImageCacheService(imageNetwork: ImageNetwork())
    
    private let imageNetwork: ImageNetwork
    private let cachedImages = NSCache<NSString, UIImage>()
    
    private init(imageNetwork: ImageNetwork) {
        self.imageNetwork = imageNetwork
    }
    
    /// 이미지를 불러오는 함수
    func loadImageAsync(imageId: String) async -> UIImage? {
        // Cache에 저장된 이미지가 있는 경우 바로 반환
        if let cachedImage = image(imageId: imageId) {
            return cachedImage
        }
        
        // Cache에 저장된 이미지가 없는 경우 서버에서 이미지 불러오기
        let res = await imageNetwork.getImage(imageId: imageId)
        switch res {
        case .success(let uiImage):
            setCachedImage(imageId: imageId, image: uiImage)
            return uiImage
        case .failure:
            return nil
        }
    }
    
    /// Cache에 저장된 이미지가 있는지 확인
    private final func image(imageId: String) -> UIImage? {
        return cachedImages.object(forKey: imageId as NSString)
    }
    
    /// Cache에 이미지를 저장하는 함수
    private func setCachedImage(imageId: String, image: UIImage) {
        cachedImages.setObject(image, forKey: imageId as NSString)
    }
}
