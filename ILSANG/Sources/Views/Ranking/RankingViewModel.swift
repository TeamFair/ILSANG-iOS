//
//  RankingViewModel.swift
//  ILSANG
//
//  Created by Kim Andrew on 10/7/24.
//

import Combine
import UIKit

@MainActor
class RankingViewModel: ObservableObject {
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loaded
    @Published var selectedPointType: PointType = .metro
    
    @Published var selectedSeason: Season?
    var selectedSeasonId: Int? {
        selectedSeason?.id
    }
    @Published var showSelectSeasonView = false
    @Published var showRankingDetailView = false
    @Published var selectedRank: AreaRankItem?
    
    @Published var metroRank: [AreaRankItem] = []
    @Published var commercialRank: [AreaRankItem] = []
    @Published var contributionRank: [UserRankItem] = []
    
    @Published var seasons: [Season] = []
    
    private let rankRepository: RankRepositoryInterface
    private let areaNameService: AreaNameProvider
    let seasonManager: SeasonManager
    
    private var currentLoadTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    init(rankRepository: RankRepositoryInterface, areaNameService: AreaNameProvider, seasonManager: SeasonManager)  {
        self.rankRepository = rankRepository
        self.areaNameService = areaNameService
        self.seasonManager = seasonManager
        
        selectedSeason = seasonManager.currentSeason ?? nil // 현재시즌으로 초기화
        seasonManager.$seasons
            .removeDuplicates()
            .sink { [weak self] seasons in
                guard let self else { return }
                self.seasons = seasons
            }
            .store(in: &cancellables)
        
        seasonManager.$currentSeason
            .removeDuplicates()
            .sink { [weak self] season in
                guard let self else { return }
                self.selectedSeason = season
            }
            .store(in: &cancellables)
        
        Log("🏆 RankingViewModel: init")
    }
    
    deinit {
        cancellables.removeAll()
        Log("🏆 RankingViewModel: deinit")
    }
    
    func reset() {
        currentLoadTask?.cancel()
        self.metroRank = []
        self.commercialRank = []
        self.contributionRank = []
        currentLoadTask = Task {
            await self.loadRankInternal(type: self.selectedPointType)
        }
    }
    
    func loadRankIfNeeded(type: PointType) async {
        switch type {
        case .metro:
            if !metroRank.isEmpty { return }
        case .commercial:
            if !commercialRank.isEmpty { return }
        case .contribution:
            if !contributionRank.isEmpty { return }
        }
        
        await loadRank(type: type)
    }
    
    func loadRank(type: PointType) async {
        // 기존 Task가 있으면 취소
        currentLoadTask?.cancel()
        
        // 새로운 Task 생성
        currentLoadTask = Task {
            await loadRankInternal(type: type)
        }
        
        // Task 완료 대기
        await currentLoadTask?.value
    }
    
    // 실제 로드 로직
    private func loadRankInternal(type: PointType) async {
        if Task.isCancelled {
            Log("Task 취소됨 - 로드 중단")
            return
        }
        
        changeViewStatus(.loading)
        
        switch type {
        case .metro:
            let res = await rankRepository.getMetroAreaRank(seasonId: selectedSeasonId)
            if Task.isCancelled { return }
            handleAreaRankResult(res, assignTo: \.metroRank)
            
        case .commercial:
            let res = await rankRepository.getCommercialAreaRank(seasonId: selectedSeasonId)
            if Task.isCancelled { return }
            handleAreaRankResult(res, assignTo: \.commercialRank)
            
        case .contribution:
            let res = await rankRepository.getTopUserRank(seasonId: selectedSeasonId)
            if Task.isCancelled { return }
            handleUserRankResult(res, assignTo: \.contributionRank)
            await getProfileImages()
        }
    }
    
    func getProfileImages() async {
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, user) in contributionRank.enumerated() {
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
                    self.contributionRank[index].profileImage = image
                }
            }
        }
    }
    
    // MARK: - 헬퍼
    private func handleAreaRankResult(
        _ result: Result<[AreaRank], Error>,
        assignTo keyPath: ReferenceWritableKeyPath<RankingViewModel, [AreaRankItem]>
    ) {
        switch result {
        case .success(let response):
            self[keyPath: keyPath] = response.map { $0.toRankItem() }
            changeViewStatus(.loaded)
        case .failure(let error):
            Log("지역 랭킹 로드 실패: \(error)")
            if let networkError = error as? NetworkError, networkError == .unknownStatusCode(-1) || networkError == .unknownError {
                changeViewStatus(.loaded)
                return
            }
            changeViewStatus(.error)
        }
    }
    
    private func handleUserRankResult(
        _ result: Result<[UserRank], Error>,
        assignTo keyPath: ReferenceWritableKeyPath<RankingViewModel, [UserRankItem]>
    ) {
        switch result {
        case .success(let response):
            self[keyPath: keyPath] = response.map { $0.toRankItem() }
            changeViewStatus(.loaded)
        case .failure(let error):
            Log("유저 랭킹 로드 실패: \(error)")
            if let networkError = error as? NetworkError, networkError == .unknownStatusCode(-1) || networkError == .unknownError {
                changeViewStatus(.loaded)
                return
            }
            changeViewStatus(.error)
        }
    }
    
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
}
