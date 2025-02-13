//
//  ImageCacheService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/17/24.
//

import UIKit

actor ImageRequestManager {
    private var imageRequestInProgress: [String: Task<UIImage?, Never>] = [:]
    
    func getTask(for imageId: String) -> Task<UIImage?, Never>? {
        return imageRequestInProgress[imageId]
    }
    
    func setTask(_ task: Task<UIImage?, Never>, for imageId: String) {
        imageRequestInProgress[imageId] = task
    }
    
    func removeTask(for imageId: String) {
        imageRequestInProgress.removeValue(forKey: imageId)
    }
}

final class ImageCacheService {
    public static let shared = ImageCacheService(imageNetwork: ImageNetwork())
    
    private let imageNetwork: ImageNetwork
    private let cachedImages = NSCache<NSString, UIImage>()
    private let requestManager = ImageRequestManager()
    
    private init(imageNetwork: ImageNetwork) {
        self.imageNetwork = imageNetwork
    }
    
    func loadImageAsync(imageId: String) async -> UIImage? {
        // Cache에 저장된 이미지가 있는 경우 바로 반환
        if let cachedImage = image(imageId: imageId) {
            return cachedImage
        }
        
        if let ongoingTask = await requestManager.getTask(for: imageId) {
            return await ongoingTask.value
        }
        
        let task = Task { [weak self] () -> UIImage? in
            defer {
                Task {
                    await self?.requestManager.removeTask(for: imageId)
                }
            }
            
            let result = await self?.imageNetwork.getImage(imageId: imageId)
            switch result {
            case .success(let uiImage):
                self?.setCachedImage(imageId: imageId, image: uiImage)
                return uiImage
            case .failure:
                return nil
            case .none:
                return nil
            }
        }
        
        await requestManager.setTask(task, for: imageId)
        return await task.value
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
