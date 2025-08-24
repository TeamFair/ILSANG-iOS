//
//  ImageChallengeSubmitService.swift
//  ILSANG
//
//  Created by Lee Jinhee on 2/27/25.
//

import UIKit

final class ImageChallengeSubmitService {
    private let imageNetwork: ImageNetwork
    private let challengeNetwork: ChallengeNetwork
    private var images: [String] = []
    
    init(imageNetwork: ImageNetwork, challengeNetwork: ChallengeNetwork) {
        self.imageNetwork = imageNetwork
        self.challengeNetwork = challengeNetwork
    }
    
    /// 도전 과제 제출 실행
    func execute(missionId: Int, image: UIImage?) async -> Bool {
        guard let image = image else { return false }
        
        // 1. 이미지 업로드
        guard let imageId = await postImage(image) else { return false }
        
        // 2. 챌린지 제출
        return await postChallenge(missionId: missionId, imageId: imageId)
    }
    
    /// 이미지 업로드
    private func postImage(_ image: UIImage) async -> String? {
        let result = await imageNetwork.postImage(image: image, type: .receipt)
        if case .success(let response) = result {
            self.images.append(response.imageId)
            return response.imageId
        }
        return nil
    }
    
    /// 챌린지 제출
    private func postChallenge(missionId: Int, imageId: String) async -> Bool {
        let result = await challengeNetwork.postPhotoChallenge(missionId: missionId, imageId: imageId)
        switch result {
        case .success:
            await cleanUpImages(except: imageId)
            return true
        case .failure(let error):
            Log("도전내역 등록 실패 \(error.localizedDescription)")
            return false
        }
    }
    
    /// 업로드된 이미지 정리 (가장 최근 이미지는 제외)
    private func cleanUpImages(except imageId: String) async {
        self.images.removeLast() // 가장 최근 추가된 이미지 삭제
        for oldImageId in images {
            let _ = await imageNetwork.deleteImage(imageId: oldImageId)
        }
        self.images.removeAll() // 정리 후 배열 비우기
    }
}
