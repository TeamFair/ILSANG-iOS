//
//  LegendRankingViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/17/25.
//

import UIKit

final class LegendRankingViewModel: ObservableObject {
    @Published var historyRanks: [LegendRankItem] = []
    private let titleId: String
    let titleName: String
    private let titleRepository: TitleRepositoryInterface
    
    init(titleId: String, titleName: String, titleRepository: TitleRepositoryInterface) {
        self.titleId = titleId
        self.titleName = titleName
        self.titleRepository = titleRepository
    }
    
    @MainActor
    func fetchLegendRanks(page: Int = 1, size: Int = 10) async {
        let result = await titleRepository.getLegendRank(titleId: titleId, page: page, size: size)
        switch result {
        case .success(let res):
            self.historyRanks = res.data.compactMap { $0.toItem() }
            await self.getProfileImages()
        case .failure(let error):
            Log("전설 칭호 조회 실패: \(error)")
        }
    }
    
    func getProfileImages() async {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, rank) in historyRanks.enumerated() {
                group.addTask {
                    guard let imageId = rank.profileImageId else {
                        return (index, nil)
                    }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image {
                    self.historyRanks[index].profileImage = image
                }
            }
        }
    }
}
