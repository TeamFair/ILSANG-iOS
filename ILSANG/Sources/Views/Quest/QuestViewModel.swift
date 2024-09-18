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
    
    var isCurrentListEmpty: Bool {
        switch selectedHeader {
        case .uncompleted:
            return itemListByStatus[.uncompleted, default: []].isEmpty
        case .completed:
            return itemListByStatus[.completed, default: []].isEmpty
        }
    }
    var isCompletedQuestPageable: Bool = false
    var isUncompletedQuestPageable: Bool = false
    
    private let imageNetwork: ImageNetwork
    private let questNetwork: QuestNetwork
    
    init(imageNetwork: ImageNetwork, questNetwork: QuestNetwork) {
        self.imageNetwork = imageNetwork
        self.questNetwork = questNetwork
        
        Task {
            await loadInitialData()
        }
    }
    
    func loadInitialData() async {
        await changeViewStatus(.loading)
        await loadQuestListWithImage(page: 0, status: .uncompleted)
        await loadQuestListWithImage(page: 0, status: .completed)
        await changeViewStatus(.loaded)
    }
    
    @MainActor
    func changeViewStatus(_ viewStatus: ViewStatus) {
        self.viewStatus = viewStatus
    }
    
    @MainActor
    func loadQuestListWithImage(page: Int, status: QuestStatus) async {
        var newQuestList = await getQuestList(page: page, status: status)
        var currentQuestList = itemListByStatus[status, default: []]
        
        if page == 0 {
            currentQuestList = newQuestList
        } else {
            // MARK: 중복된 퀘스트 제거, 서버 에러 해결시 제거
            var uniqueQuestIDs = Set(currentQuestList.map { $0.id })
            newQuestList = newQuestList.filter { uniqueQuestIDs.insert($0.id).inserted }
            currentQuestList += newQuestList
        }
        
        await withTaskGroup(of: (Int, UIImage?).self) { group in
            for (index, quest) in newQuestList.enumerated() {
                group.addTask {
                    guard let imageId = quest.imageId else {
                        return (index, nil)
                    }
                    let image = await self.getImage(imageId: imageId)
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
    }
    
    private func getQuestList(page: Int, status: QuestStatus) async -> [QuestViewModelItem] {
        let result: Result<ResponseWithPage<[Quest]>, Error>
        
        switch status {
        case .uncompleted:
            result = await questNetwork.getUncompletedQuest(page: page)
        case .completed:
            result = await questNetwork.getCompletedQuest(page: page)
        }
        
        switch result {
        case .success(let response):
            let hasMorePages = (page + 1) * response.size < response.total
            setPageableStatus(status: status, hasMorePages: hasMorePages)
            return response.data.map { QuestViewModelItem(quest: $0) }
        case .failure:
            setPageableStatus(status: status, hasMorePages: false)
            return []
        }
    }
    
    private func setPageableStatus(status: QuestStatus, hasMorePages: Bool) {
        switch status {
        case .uncompleted:
            isUncompletedQuestPageable = hasMorePages
        case .completed:
            isCompletedQuestPageable = hasMorePages
        }
    }
    
    private func getImage(imageId: String) async -> UIImage? {
        let res = await imageNetwork.getImage(imageId: imageId)
        switch res {
        case .success(let uiImage):
            return uiImage
        case .failure:
            return nil
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
