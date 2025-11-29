//
//  RankingDetailViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/24/25.
//


import UIKit

class RankingDetailViewModel: ObservableObject {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    enum AreaType {
        case metro
        case commercial
    }
    @Published var viewStatus: ViewStatus = .loading // TODO: 변경
    @Published var areaUserRank: AreaUserRankItem = .init(ranks: [], user: nil)  // TODO: 변경
    @Published var imageList: [UIImage] = []
    @Published var imageIdx = 0
    
    let seasonId: Int?
    let areaName: String
    let areaRank: Int
    let areaPoint: Int
    let areaImageIds: [String]
    
    let areaCode: String
    let areaType: AreaType
    private let rankRepository: RankRepositoryInterface
    let areaNameService: AreaNameProvider
    
    init(
        seasonId: Int?,
        areaName: String,
        areaRank: Int,
        areaPoint: Int,
        areaImageIds: [String],
        areaCode: String,
        areaType: AreaType,
        rankRepository: RankRepositoryInterface,
        areaNameService: AreaNameProvider
    ) {
        self.seasonId = seasonId
        self.areaName = areaName
        self.areaRank = areaRank
        self.areaPoint = areaPoint
        self.areaImageIds = areaImageIds
        self.areaCode = areaCode
        self.areaType = areaType
        self.rankRepository = rankRepository
        self.areaNameService = areaNameService
    }
    
    @MainActor
    func getRankDetail() async {
        viewStatus = .loading
        
        let res: Result<AreaUserRank, Error>
        switch areaType {
        case .metro:
            res = await rankRepository.getTopUserRank(metroAreaCode: areaCode, seasonId: seasonId)
        case .commercial:
            res = await rankRepository.getTopUserRank(commercialAreaCode: areaCode, seasonId: seasonId)
        }
        
        switch res {
        case .success(let data):
            self.areaUserRank = data.toRankItem()
            await getCurrentUserProfileImage()
            await getProfileImages()
            viewStatus = .loaded
        case .failure:
            viewStatus = .error
        }
    }
    
    @MainActor
    func getImages() async {
        await withTaskGroup(of: UIImage?.self) { group in
            for id in areaImageIds {
                group.addTask {
                    await ImageCacheService.shared.loadImageAsync(imageId: id)
                }
            }
            
            var results: [UIImage] = []
            for await image in group {
                if let image = image {
                    results.append(image)
                }
            }
            
            // 메인 스레드에서 반영
            self.imageList = results
        }
    }
    
    func getCurrentUserProfileImage() async {
        if let imageId = areaUserRank.user?.profileImageId {
            self.areaUserRank.user?.profileImage = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
        }
    }
    
    @MainActor
    func getProfileImages() async {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, user) in areaUserRank.ranks.enumerated() {
                group.addTask {
                    guard let imageId = user.profileImageId else {
                        return (index, nil)
                    }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image {
                    self.areaUserRank.ranks[index].profileImage = image
                }
            }
        }
        dump(areaUserRank.ranks)

    }
    
}
