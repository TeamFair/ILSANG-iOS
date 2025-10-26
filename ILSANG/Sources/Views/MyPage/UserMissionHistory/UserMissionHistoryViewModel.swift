//
//  MissionHistoryViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 8/28/25.
//


import SwiftUI

@MainActor
final class UserMissionHistoryViewModel: ObservableObject {
    @Published var missionHistories: [MissionType: [UserMissionHistoryItem]] = [:]
    @Published var selectedMissionHistoryDetail: UserMissionHistoryDetailItem?
    @Published var selectedMissionType: MissionType = .photo
    @Published var challengeDelete = false
    
    var currentMissionHistories: [UserMissionHistoryItem] {
        switch selectedMissionType {
        case .photo:
            return missionHistories[.photo, default: []]
        case .quiz(.ox):
            return missionHistories[.quiz(.ox), default: []]
        case .quiz(.text):
            return missionHistories[.quiz(.text), default: []]
        }
    }
    
    var isCurrentListEmpty: Bool {
        currentMissionHistories.isEmpty
    }
    
    var hasMorePage: Bool {
        self.paginationManager(for: selectedMissionType).canLoadMoreData()
    }
    
    var filterState: StaticFilterPickerState<MissionHistoryFilterType>
    
    private let missionHistoryRepository: MissionHistoryRepositoryInterface
    
    init(missionHistoryRepository: MissionHistoryRepositoryInterface, challengeDelete: Bool = false) {
        self.missionHistoryRepository = missionHistoryRepository
        filterState = StaticFilterPickerState<MissionHistoryFilterType>(initialValue: .latest)
        filterState.onSelectionChange = { [weak self] _ in
            guard let self = self else { return }
            Task {
                await self.paginationManager(for: self.selectedMissionType).loadData(isRefreshing: true)
            }
        }
        
        self.photoPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadPhotoMissionHistory(page: page, size: 10)
        }
        self.oxPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuizMissionHistory(page: page, size: 10, quizType: .ox, filterType: self.filterState.selectedValue)
        }
        self.textPaginationManager.loadPageData = { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuizMissionHistory(page: page, size: 10, quizType: .text, filterType: self.filterState.selectedValue)
        }
    }
    
    private var photoPaginationManager = PaginationManager<UserMissionHistoryItem>(size: 10, threshold: 7)
    private var oxPaginationManager = PaginationManager<UserMissionHistoryItem>(size: 10, threshold: 7)
    private var textPaginationManager = PaginationManager<UserMissionHistoryItem>(size: 10, threshold: 7)
    
    func loadDataIfNeeded() async {
        if isCurrentListEmpty {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        async let photoLoad: () = photoPaginationManager.loadData(isRefreshing: true)
        //        async let oxLoad: () = oxPaginationManager.loadData(isRefreshing: true)
        //        async let textLoad: () = textPaginationManager.loadData(isRefreshing: true)
        _ = await (photoLoad/*, oxLoad, textLoad*/)
    }
    
    func loadCurrentData() async {
        if isCurrentListEmpty {
            await self.paginationManager(for: self.selectedMissionType).loadData(isRefreshing: true)
        }
    }
    
    @discardableResult
    private func loadPhotoMissionHistory(page: Int, size: Int) async -> ([UserMissionHistoryItem], Int) {
        let response = await fetchMissionHistories(page: page, size: size, missionType: .photo, filterType: filterState.selectedValue)
        let newItems = response.data
        
        if page == 0 {
            self.missionHistories[.photo, default: []] = newItems
        } else {
            self.missionHistories[.photo, default: []] += newItems
        }
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, challenge) in newItems.enumerated() {
                group.addTask {
                    let imageId = challenge.submitImageId
                    var image: UIImage? = nil
                    if let imageId {
                        image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    }
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image = image {
                    if page == 0 {
                        self.missionHistories[.photo, default: []][index].submitImage = image
                    } else {
                        let startIndex = (self.missionHistories[.photo]?.count ?? 0) - newItems.count
                        let targetIndex = startIndex + index
                        if self.missionHistories[.photo, default: []].indices.contains(targetIndex) {
                            self.missionHistories[.photo, default: []][targetIndex].submitImage = image
                        }
                    }
                }
            }
        }
        
        return (missionHistories[.photo, default: []], response.total)
    }
    
    @discardableResult
    private func loadQuizMissionHistory(page: Int, size: Int, quizType: QuizType, filterType: MissionHistoryFilterType) async -> ([UserMissionHistoryItem], Int) {
        let response = await fetchMissionHistories(page: page, size: size, missionType: .quiz(quizType), filterType: filterType)
        let newItems = response.data
        
        if page == 0 {
            self.missionHistories[.quiz(quizType), default: []] = newItems
        } else {
            self.missionHistories[.quiz(quizType), default: []] += newItems
        }
        
        return (missionHistories[.quiz(quizType), default: []], response.total)
    }
    
    private func fetchMissionHistories(page: Int, size: Int, missionType: MissionType, filterType: MissionHistoryFilterType) async -> (data: [UserMissionHistoryItem], total: Int) {
        let response = await missionHistoryRepository.getMissionHistories(page: page, size: size, userId: nil, missionType: missionType, filterType: filterType)
        
        switch response {
        case .success(let res):
            // 데이터 초기화: 이미지가 없는 상태로 미리 표시
            return (res.data.map { $0.toItem() }, res.total)
        case .failure(let error):
            Log("챌린지 조회 실패: \(error)")
            return ([], 0)
        }
    }
    
    func fetchMissionHistoryDetail(id: Int, submitImage: UIImage?) async {
        let response = await missionHistoryRepository.getMissionHistoryDetail(missionHistoryId: id)
        switch response {
        case .success(let res):
            self.selectedMissionHistoryDetail = res.toItem( submitImage: submitImage)
        case .failure(let error):
            self.selectedMissionHistoryDetail = nil
            Log("챌린지 상세 조회 실패: \(error)")
        }
    }
     
    func deleteMissionHistory(id: Int) async -> Bool {
        return await missionHistoryRepository.deleteMissionHistory(missionHistoryId: id)
    }
    
    func getImage(imageId: String) async -> UIImage? {
        await ImageCacheService.shared.loadImageAsync(imageId: imageId)
    }
    
    func paginationManager(for type: MissionType) -> PaginationManager<UserMissionHistoryItem> {
        switch type {
        case .photo: return photoPaginationManager
        case .quiz(.ox): return oxPaginationManager
        case .quiz(.text): return textPaginationManager
        }
    }
    
    func closeFilterPicker() {
        self.filterState.pickerStatus  = .close
    }
}
