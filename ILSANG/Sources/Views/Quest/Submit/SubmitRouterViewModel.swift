//
//  SubmitViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/27/24.
//

import SwiftUI

@MainActor
class SubmitRouterViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var showSubmitAlertView: Bool = false
    @Published var submitStatus: SubmitStatus = .submit
    
    private let submitService: ImageChallengeSubmitService
    
    let selectedQuest: QuestViewModelItem
    private var submitTask: Task<Void, Never>?
    
    init(selectedImage: UIImage? = nil, selectedQuest: QuestViewModelItem, submitService: ImageChallengeSubmitService) {
        self.selectedImage = selectedImage
        self.selectedQuest = selectedQuest
        self.submitService = submitService
    }
    
    /// 제출 요청
    func submit() {
        self.showSubmitAlertView = true
        self.startSubmitTask()
    }
    
    /// 제출 작업 시작
    private func startSubmitTask() {
        if submitTask == nil || submitTask?.isCancelled == true { // 이거 추가함!!!!
            submitTask = Task {
                await self.postChallengeWithImage()
            }
        }
    }
    
    /// 제출 작업 취소  & 상태 변경
    func cancelSubmitTask() {
        submitTask?.cancel()
        submitTask = nil
        submitStatus = .fail
    }
    
    /// scenePhase 변경 시 호출. 활성화 상태로 변한게 아니면 작업 취소
    func handleScenePhaseChange(to newPhase: ScenePhase) {
        if newPhase != .active {
            cancelSubmitTask()
        }
    }
    
    func clearSelectedImage() {
        self.showSubmitAlertView = false
        self.selectedImage = nil
    }
    
    @MainActor
    func postChallengeWithImage() async {
        submitStatus = .submit
        
        let isSuccess = await submitService.execute(questId: selectedQuest.id, image: selectedImage)
        
        if isSuccess {
            submitStatus = .complete
        } else {
            submitStatus = .fail
        }
    }
}
