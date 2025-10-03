//
//  MyPageHonorManageViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import Foundation

@MainActor
final class MyPageHonorManageViewModel: ObservableObject {
    @Published var honors: [HonorGrade: [TitleItem]] = [.standard: [], .rare: [], .legend: []]
    @Published var selectedHonorGrade: HonorGrade = .standard
    @Published var isShowHonorInfoPopup: Bool = false
    @Published var showRankingView: Bool = false
    @Published var selectedHonorToShowRanking: TitleItem?
    
    @Published var selectedHistoryId: Int?
    private let initialHonor: UserTitle?
    private var initialHistoryId: Int? = nil
    
    private let titleRepository: TitleRepositoryInterface
    private let userNetwork: UserNetwork
    
    init(userNetwork: UserNetwork, titleRepository: TitleRepositoryInterface) {
        self.userNetwork = userNetwork
        self.titleRepository = titleRepository
        self.initialHonor = UserService.shared.currentUser?.title ?? nil
        self.initialHistoryId = initialHonor?.titleHistoryId
    }
    
    func fetchHonors() async {
        async let honorsResponse = fetchTitles()
        async let historiesResponse = fetchTitleHistories()
        
        let honors = await honorsResponse
        let histories = await historiesResponse
        dump(initialHistoryId)
        let items = honors.map { $0.toItem(userTitles: histories, currentSelectedId: initialHistoryId) }
        
        await MainActor.run {
            self.honors = Dictionary(grouping: items, by: \.grade)
            self.selectedHistoryId = initialHistoryId
        }
    }
    
    func selectHonor(_ honor: TitleItem) {
        guard honor.isAcquired else { return }
        
        // 같은 거 누르면 해제
        if honor.historyId == selectedHistoryId {
            deselectHonor(honor.historyId!)
            return
        }
        
        // 이전 선택 해제
        if let previousId = selectedHistoryId {
            deselectHonor(previousId)
        }
        
        // 새 선택
        selectNewHonor(honor)
    }
    
    private func deselectHonor(_ historyId: Int) {
        for grade in honors.keys {
            if let index = honors[grade]?.firstIndex(where: { $0.historyId == historyId }) {
                honors[grade]?[index].isSelected = false
            }
        }
        selectedHistoryId = nil
    }
    
    private func selectNewHonor(_ honor: TitleItem) {
        guard let index = honors[honor.grade]?.firstIndex(where: { $0.id == honor.id }) else { return }
        honors[honor.grade]?[index].isSelected = true
        selectedHistoryId = honors[honor.grade]?[index].historyId
    }
    
    private func fetchTitles() async -> [Title] {
        let response = await titleRepository.getTitles()
        switch response {
        case .success(let res):
            return res
        case .failure(let error):
            Log("칭호 조회 실패: \(error)")
            return []
        }
    }
    
    private func fetchTitleHistories() async -> [UserTitle] {
        let response = await titleRepository.getTitleHistories()
        
        switch response {
        case .success(let res):
            return res
        case .failure(let error):
            Log("칭호 조회 실패: \(error)")
            return []
        }
    }
    
    func updateHonorIfNeeded() async {
        guard selectedHistoryId != initialHistoryId else {
            Log("칭호 변경 없음: 업데이트 생략 - 이미 업데이트된 칭호")
            return
        }
        
        let updateSucc = await userNetwork.putHonor(historyId: selectedHistoryId ?? nil)
        Log("칭호 변경 있음: 업데이트 \(updateSucc ? "성공" : "실패") with \(selectedHistoryId ?? -1)")
    }
    
    func showHonorInfoPopup() {
        isShowHonorInfoPopup = true
    }
    
    func closeHonorInfoPopup() {
        isShowHonorInfoPopup = false
    }
    
    func navigateToRankingView(honor: TitleItem) {
        selectedHonorToShowRanking = honor
        showRankingView = true
    }
}
