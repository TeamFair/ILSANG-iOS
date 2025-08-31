//
//  AreaRankViewModelItem.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/25/25.
//


import UIKit

class AreaRankViewModelItem: ObservableObject, Identifiable, Hashable {
    static func == (lhs: AreaRankViewModelItem, rhs: AreaRankViewModelItem) -> Bool {
        lhs.areaCode == rhs.areaCode && lhs.rank == rhs.rank
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(areaCode)
        hasher.combine(rank)
    }
    
    let areaCode: String
    let areaName: String
    let point: Int
    let imageIds: [String]
    @Published var images: [UIImage] = []
    let rank: Int
    
    init(areaCode: String, areaName: String, point: Int, imageIds: [String], rank: Int) {
        self.areaCode = areaCode
        self.areaName = areaName
        self.point = point
        self.imageIds = imageIds
        self.rank = rank
    }
    
    func loadImages() {
        Task {
            let images = await withTaskGroup(of: (Int, UIImage?).self, returning: [UIImage].self) { group in
                for (index, id) in imageIds.enumerated() {
                    group.addTask {
                        let img = await ImageCacheService.shared.loadImageAsync(imageId: id)
                        return (index, img)
                    }
                }
                
                var results = Array<UIImage?>(repeating: nil, count: imageIds.count)
                for await (index, img) in group {
                    results[index] = img
                }
                
                return results.compactMap { $0 }
            }
            
            await MainActor.run {
                self.images = images
            }
        }
    }
}

extension AreaRankViewModelItem {
    static let mockData1 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 10000, imageIds: [], rank: 1)
    static let mockData100 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 10000, imageIds: [], rank: 100)
    static let mockData1000 = AreaRankViewModelItem(areaCode: "", areaName: "서현", point: 100, imageIds: [], rank: 1000)
}
