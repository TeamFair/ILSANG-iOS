//
//  QuestViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/23/24.
//

import UIKit
import SwiftUI

class QuestViewModel: ObservableObject {
    // TODO: API 요청 실패 시 에러상태로 변경하기
    enum ViewStatus {
        case error
        case loading
        case loaded
    }
    
    @Published var viewStatus: ViewStatus = .loading
    @Published var selectedHeader: QuestStatus = .uncompleted
    @Published var selectedXpStat: XpStat = .strength
    @Published var selectedQuest: QuestViewModelItem = .mockData
    @Published var showQuestSheet: Bool = false
    @Published var showSubmitRouterView: Bool = false {
        didSet {
            // TODO: 도전내역 등록 완료시 리스트에서 퀘스트만 삭제/추가하도록 개선(퀘스트 조회 API 호출x)
            if showSubmitRouterView == false {
                Task {
                    await loadInitialData()
                }
            }
        }
    }
    @Published var itemListByStatus: [QuestStatus: [QuestViewModelItem]] = [
        .uncompleted: [],
        .completed: []
    ]
    @Published var uncompletedQuestListByXpStat: [XpStat: [QuestViewModelItem]] = Dictionary(uniqueKeysWithValues: XpStat.allCases.map { ($0, []) })
    
    var isCurrentListEmpty: Bool {
        switch selectedHeader {
        case .uncompleted:
            return itemListByStatus[.uncompleted, default: []].isEmpty
        case .completed:
            return itemListByStatus[.completed, default: []].isEmpty
        }
    }
    
    // TODO: 현재 0페이지만 불러오며, 임시로 100개 로딩. 스탯 분류와 관련해서 기획 & API 수정에 따라 페이지네이션 로직 수정 필요
    lazy var uncompletedPaginationManager = PaginationManager<QuestViewModelItem>(
        size: 100,
        threshold: 98,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuestListWithImage(page: page, size: 100, status: .uncompleted)
        }
    )
    
    lazy var completedPaginationManager = PaginationManager<QuestViewModelItem>(
        size: 10,
        threshold: 8,
        loadPage: { [weak self] page in
            guard let self = self else { return ([], 0) }
            return await loadQuestListWithImage(page: page, size: 10, status: .completed)
        }
    )
    
    // MARK: throttle 관련
    let throttleInterval: TimeInterval = 2.0
    var lastRefreshTime: Date? = nil
    
    private let questNetwork: QuestNetwork
    
    init(questNetwork: QuestNetwork) {
        self.questNetwork = questNetwork
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        await changeViewStatus(.loading)
        await uncompletedPaginationManager.loadData(isRefreshing: true)
        await completedPaginationManager.loadData(isRefreshing: true)
        await changeViewStatus(.loaded)
    }
    
    func refreshData() async {
        // 마지막 새로고침으로부터 throttleInterval 이내에 새로 고침 시도를 방지
        let now = Date()

        if let lastRefreshTime = lastRefreshTime, now.timeIntervalSince(lastRefreshTime) < throttleInterval {
            return
        }
        lastRefreshTime = now

        switch selectedHeader {
        case .uncompleted:
            await uncompletedPaginationManager.loadData(isRefreshing: true)
        case .completed:
            await completedPaginationManager.loadData(isRefreshing: true)
        }
        
        lastRefreshTime = Date()
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    @discardableResult @MainActor
    func loadQuestListWithImage(page: Int, size: Int, status: QuestStatus) async -> ([QuestViewModelItem], Int) {
        let getQuestList = await getQuestList(page: page, size: size, status: status)
        var newQuestList = getQuestList.data
        var currentQuestList = itemListByStatus[status, default: []]
        
        if page == 0 {
            currentQuestList = newQuestList
        } else {
            // MARK: 중복된 퀘스트 제거, 서버 에러 해결시 제거
            newQuestList = newQuestList.filter { quest in
                !currentQuestList.contains { $0.id == quest.id }
            }
            currentQuestList += newQuestList
        }
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, quest) in newQuestList.enumerated() {
                group.addTask {
                    guard let imageId = quest.imageId else {
                        return (index, nil)
                    }
                    let image = await ImageCacheService.shared.loadImageAsync(imageId: imageId)
                    return (index, image)
                }
            }
            
            for await (index, image) in group {
                if let image = image {
                    if page == 0 {
                        currentQuestList[index].image = image
                    } else {
                        currentQuestList[currentQuestList.count - newQuestList.count + index].image = image
                    }
                }
            }
        }
        itemListByStatus[status] = currentQuestList
        
        if status == .uncompleted {
            mapUncompletedQuestByXpStat()
        }
        return (itemListByStatus[status, default: []], getQuestList.total)
    }
    
    /// uncompleted 상태의 퀘스트 목록을 XpStat별로 분류하여 uncompletedQuestListByXpStat 딕셔너리에 매핑합니다.
    private func mapUncompletedQuestByXpStat() {
        guard let uncompletedQuestList = itemListByStatus[.uncompleted] else { return }
        self.uncompletedQuestListByXpStat = self.uncompletedQuestListByXpStat.mapValues { _ in [] } // 초기화
        
        for item in uncompletedQuestList {
            for reward in item.rewardDic {
                uncompletedQuestListByXpStat[reward.key]?.append(item)
            }
        }
    }
    
    private func getQuestList(page: Int, size: Int, status: QuestStatus) async -> (data: [QuestViewModelItem], total: Int) {
        let result: Result<ResponseWithPage<[Quest]>, Error>
        
        switch status {
        case .uncompleted:
            result = await questNetwork.getUncompletedQuest(page: page, size: size)
        case .completed:
            result = await questNetwork.getCompletedQuest(page: page, size: size)
        }
        
        switch result {
        case .success(let response):
            return (response.data.map { QuestViewModelItem(quest: $0) }, response.total)
        case .failure:
            return ([], 0)
        }
    }
    
    func hasMorePage(status: QuestStatus) -> Bool {
        switch status {
        case .uncompleted:
            return uncompletedPaginationManager.canLoadMoreData()
        case .completed:
            return completedPaginationManager.canLoadMoreData()
        }
    }
    
    func tappedQuestBtn(quest: QuestViewModelItem) {
        selectedQuest = quest
        showQuestSheet.toggle()
    }
    
    func tappedQuestApprovalBtn() {
        showSubmitRouterView.toggle()
        showQuestSheet.toggle()
    }
}

struct VLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}
