//
//  MyPageHonorManageViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/13/25.
//

import Foundation

final class MyPageHonorManageViewModel: ObservableObject {
    @Published var honors: [HonorGrade: [HonorItem]] = [.standard: [], .rare: [], .legend: []]
    @Published var selectedHonorGrade: HonorGrade = .standard
    @Published var isShowHonorInfoPopup: Bool = false
    @Published var showRankingView: Bool = false
    @Published var selectedHonorToShowRanking: HonorItem?
    
    @Published var selectedHistoryId: String?
    private let initialHonor = UserService.shared.currentUser?.title
    private var initialHistoryId: String? = nil

    private let honorNetwork: HonorNetwork
    private let userNetwork: UserNetwork
    
    init(userNetwork: UserNetwork, honorNetwork: HonorNetwork) {
        self.userNetwork = userNetwork
        self.honorNetwork = honorNetwork
    }
    
    func fetchHonors() async {
        let honors = await self.fetchHonorTitles()
        await MainActor.run {
            self.honors = Dictionary(grouping: honors, by: \.type)
        }
        
        // 초기 historyId, isSelected 업데이트
        for (type, items) in self.honors {
            for i in 0..<items.count {
                let item = items[i]
                if item.titleId == self.initialHonor?.id {
                    await MainActor.run {
                        self.selectedHistoryId = item.historyId
                        self.initialHistoryId = item.historyId
                        self.honors[type, default: []][i].isSelected = true
                    }
                }
            }
        }
    }
    
    func selectHonor(_ honor: HonorItem) {
        guard honor.isAcquired else { return }

        // 이전 선택 해제
        if let previousId = selectedHistoryId {
            deselectHonor(previousId)
        }
        
        // 동일한 항목을 다시 누르면 선택 해제
        if honor.historyId == selectedHistoryId {
            selectedHistoryId = nil
        } else {
            // 새로운 항목 선택
            selectNewHonor(honor)
        }
    }
    
    private func deselectHonor(_ historyId: String) {
        for (grade, items) in honors {
            if let index = items.firstIndex(where: { $0.historyId == historyId }) {
                honors[grade, default: []][index].isSelected = false
            }
        }
    }
    
//    private func selectNewHonor(_ honor: HonorItem) {
//        let grade = honor.type
//        if let index = honors[honor.type, default: []].firstIndex(where: { $0.id == honor.id }) {
//            honors[grade]?[index].isSelected = true
//            selectedHistoryId = honors[grade]?[index].historyId
//        }
//    }
    
    private func selectNewHonor(_ honor: HonorItem) {
        guard let index = honors[honor.type]?.firstIndex(where: { $0.id == honor.id }) else { return }
        honors[honor.type]?[index].isSelected = true
        selectedHistoryId = honors[honor.type]?[index].historyId
    }
    
    
    private func fetchHonorTitles() async -> [HonorItem] {
        let response = await honorNetwork.getHonorHistory()
        
        switch response {
        case .success(let res):
            return res.data.map { $0.toDomain() }
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

        let updateSucc = await userNetwork.putHonor(historyId: selectedHistoryId ?? "")
       
        Log("칭호 변경 있음: 업데이트 \(updateSucc ? "성공" : "실패") with \(selectedHistoryId ?? "_")")
    }
    
    func showHonorInfoPopup() {
        isShowHonorInfoPopup = true
    }
    
    func closeHonorInfoPopup() {
        isShowHonorInfoPopup = false
    }
    
    func navigateToRankingView(honor: HonorItem) {
        selectedHonorToShowRanking = honor
        showRankingView = true
    }
}
