//
//  SubmitAlertViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 6/27/24.
//

import UIKit

class SubmitAlertViewModel: ObservableObject {
    @Published var selectedImage: UIImage?
    @Published var submitStatus: SubmitStatus = .submit
    @Published var showSubmitAlertView: Bool
    let selectedQuest: QuestViewModelItem
    
    private let imageNetwork: ImageNetwork
    private let challengeNetwork: ChallengeNetwork

    init(selectedImage: UIImage? = nil, selectedQuest: QuestViewModelItem, imageNetwork: ImageNetwork, challengeNetwork: ChallengeNetwork, showSubmitAlertView: Bool) {
        self.selectedImage = selectedImage
        self.selectedQuest = selectedQuest
        self.imageNetwork = imageNetwork
        self.challengeNetwork = challengeNetwork
        self.showSubmitAlertView = showSubmitAlertView
    }
    
    @MainActor
    func postChallengeWithImage() async {
        submitStatus = .submit

        // 이미지 POST
        guard let imageId = await postImage() else {
            submitStatus = .fail
            return
        }
        
        print(imageId)
        
        // 도전내역 POST
        let isPostChallengeSuccessful = await postChallenge(questId: selectedQuest.id, imageId: imageId)
        if isPostChallengeSuccessful {
            submitStatus = .complete
        } else {
            submitStatus = .fail
        }
    }
    
    private func postImage() async -> String? {
        guard let selectedImage = selectedImage else { return nil }
        let res = await imageNetwork.postImage(image: selectedImage)
        switch res {
        case .success(let success):
            return success.imageId
        case .failure:
            return nil
        }
    }
    
    private func postChallenge(questId: String, imageId: String) async -> Bool {
        let res = await challengeNetwork.postChallenge(questId: questId, imageId: imageId)
        switch res {
        case .success:
            return true
        case .failure:
            return false
        }
    }
}
