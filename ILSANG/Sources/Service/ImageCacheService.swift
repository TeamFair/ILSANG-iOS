//
//  ImageCacheService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/17/24.
//

import UIKit

/// 이미지 요청, 메모리 & 디스크 캐시 관리
final class ImageCacheService {
    public static let shared = ImageCacheService(imageNetwork: ImageNetwork())
    
    private let imageNetwork: ImageNetwork
    private let cachedImages = NSCache<NSString, UIImage>()
    private let requestManager = ImageRequestManager()
    private let diskCache = ImageDiskCache.shared
    
    private init(imageNetwork: ImageNetwork) {
        self.imageNetwork = imageNetwork
    }
    
    func loadImageAsync(imageId: String) async -> UIImage? {
        if let ongoingTask = await requestManager.getTask(for: imageId) {
            return await ongoingTask.value
        }
        
        if let memoryCached = cachedMemoryImage(for: imageId) {
            return memoryCached
        }
        
        if let diskCached = diskCache.image(forKey: imageId) {
            setCachedImage(imageId: imageId, image: diskCached)
            return diskCached
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
                self?.diskCache.setImage(uiImage, forKey: imageId)
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
    private func cachedMemoryImage(for imageId: String) -> UIImage? {
        return cachedImages.object(forKey: imageId as NSString)
    }
    
    /// Cache에 이미지를 저장
    private func setCachedImage(imageId: String, image: UIImage) {
        cachedImages.setObject(image, forKey: imageId as NSString)
    }
    
    func removeCachedImage(imageId: String) {
        cachedImages.removeObject(forKey: imageId as NSString)
        diskCache.remove(forKey: imageId)
    }
    
    func cleanupDiskCache() {
        diskCache.cleanupExpiredImages()
    }
}

/// 디스크에 이미지 저장 + 만료 관리
final class ImageDiskCache {
    static let shared = ImageDiskCache()
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL
    private let expirationDays: Int = 7
    private let dateStoreKey = "ImageDiskCacheTimestamps"
    
    private init() {
        self.cacheDirectory = try! fileManager.url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(keyToFilename(key)).jpg")
        
        if let data = image.jpegData(compressionQuality: 1.0) {
            do {
                try data.write(to: fileURL)
                saveTimestamp(forKey: key)
                Log("DISK CACHE SAVED - DATA SIZE: \(data.count) bytes for \(key)")
            } catch {
                Log("DISK CACHE SAVE FAILED: \(key), error: \(error)")
            }
        }
    }
    
    func image(forKey key: String) -> UIImage? {
        let fileURL = cacheDirectory.appendingPathComponent("\(keyToFilename(key)).jpg")
        
        // 만료된 경우 삭제
        if !isCacheValid(forKey: key) {
            remove(forKey: key)
            removeTimestamp(forKey: key)
            return nil
        }
        
        guard let data = try? Data(contentsOf: fileURL),
              let image = UIImage(data: data) else {
            
            return nil
        }
        
        return image
    }
    
    func remove(forKey key: String) {
        let fileURL = cacheDirectory.appendingPathComponent("\(keyToFilename(key)).jpg")
        try? fileManager.removeItem(at: fileURL)
    }
    
    func cleanupExpiredImages() {
        guard let timestamps = UserDefaults.standard.dictionary(forKey: dateStoreKey) as? [String: TimeInterval] else { return }
        Log("CLEAN EXPIRED IMAGE IN DISK CACHE")
        
        for (key, time) in timestamps {
            let date = Date(timeIntervalSince1970: time)
            if Date().timeIntervalSince(date) > Double(expirationDays * 24 * 60 * 60) {
                remove(forKey: key)
                removeTimestamp(forKey: key)
            }
        }
    }
    
    private func keyToFilename(_ key: String) -> String {
        return key.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? key
    }
    
    private func saveTimestamp(forKey key: String) {
        var timestamps = UserDefaults.standard.dictionary(forKey: dateStoreKey) as? [String: TimeInterval] ?? [:]
        timestamps[key] = Date().timeIntervalSince1970
        UserDefaults.standard.set(timestamps, forKey: dateStoreKey)
    }
    
    private func isCacheValid(forKey key: String) -> Bool {
        guard let timestamps = UserDefaults.standard.dictionary(forKey: dateStoreKey) as? [String: TimeInterval],
              let timestamp = timestamps[key] else { return false }
        
        let savedDate = Date(timeIntervalSince1970: timestamp)
        return Date().timeIntervalSince(savedDate) < Double(expirationDays * 24 * 60 * 60)
    }
    
    private func removeTimestamp(forKey key: String) {
        var timestamps = UserDefaults.standard.dictionary(forKey: dateStoreKey) as? [String: TimeInterval] ?? [:]
        timestamps.removeValue(forKey: key)
        UserDefaults.standard.set(timestamps, forKey: dateStoreKey)
    }
}


/// 이미지 중복 요청 방지
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
