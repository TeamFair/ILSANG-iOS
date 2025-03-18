//
//  ProfileEditViewModel.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/10/25.
//

import UIKit

enum NicknameError: String {
    case invalidFormat = "한글+영어+숫자 포함 2 ~ 12자 이하로 닉네임을 입력해주세요."
    case duplicate = "입력하신 닉네임은 이미 사용중이에요.\n다른 닉네임을 입력해주세요." // 400
}

//enum ProfileImageError: String {
//    case size = "이미지 용량을 수정해주세요.. 시도해주세요."
//}

// - 닉네임 및 프로필 이미지 변경 상태 관리
// - 닉네임 검증(길이 제한 및 유효성 검사) 및 중복 확인
// - 프로필 업데이트 시 네트워크 요청 처리 (닉네임 및 프로필 이미지 수정)
// - 프로필 이미지 삭제 시 백엔드 및 캐시에서 제거
// - 사용자 액션에 따른 알림(Alert) 핸들링
// -- 정보 수정한 채로 화면 이탈할 경우 alertType.CancleEditProfile
// -- 프로필 이미지 삭제 시 alertType.DeleteProfileImage
class ProfileEditViewModel: ObservableObject {
    let prevName: String
    let prevImage: UIImage?
    let prevImageId: String?
    
    @Published var name: String = "" {
        didSet { validateNickname() }
    }
    @Published var nicknameError: NicknameError? // 닉네임 에러 상태 관리
    // @Published var profileImageError: ProfileImageError? // 프로필 이미지 에러 상태 관리
    
    @Published var showAlert: Bool = false
    @Published var alertType: AlertType = .CancleEditProfile
    
    @Published var showEditProfileImageSheet: Bool = false
    @Published var showPhotosPicker: Bool = false
    @Published var croppedImage: UIImage?
    
    private let characterLimit = 12
    var buttonAble: Bool {
        hasChanges && nicknameError == nil
    }
    var hasChanges: Bool {
        name != prevName || prevImage?.pngData() != croppedImage?.pngData()
    }
    
    private let userNetwork: UserNetwork
    private let imageNetwork: ImageNetwork
    
    init(name: String, image: UIImage?, imageId: String?, userNetwork: UserNetwork, imageNetwork: ImageNetwork) {
        self.userNetwork = userNetwork
        self.imageNetwork = imageNetwork
        self.prevName = name
        self.name = name
        self.prevImage = image
        self.prevImageId = imageId
        self.croppedImage = image
    }
    
    private func validateNickname() {
        if name.count > characterLimit {
            name = String(name.prefix(characterLimit))
        }
        
        if isValidNickname(name) {
            nicknameError = nil
        } else {
            nicknameError = .invalidFormat
        }
    }
    
    private func isValidNickname(_ name: String) -> Bool {
        let pattern = ".*[가-힣a-zA-Z0-9]+.*"
        let isMatched = NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: name)
        return isMatched && (2...12).contains(name.count)
    }
    
    @MainActor
    func updateProfile() async -> Bool {
        if name != prevName {
            let success = await userNetwork.putUser(nickname: name)
            if success {
                nicknameError = nil
            } else {
                // TODO: 중복인 경우(400번 에러)랑 다른 에러랑 구분해서 보여주도록 수정
                // 중복되는 아이디가 있거나 서버 연결에 문제 있을 경우
                nicknameError = .duplicate
                return false
            }
        }
        
        if prevImage != croppedImage, let croppedImage {
            let res = await imageNetwork.postImage(image: croppedImage, type: .userProfileImage)
            switch res {
            case .success(let succ):
                if prevImage != nil {
                    deleteProfileImage()
                }
                let _ = await userNetwork.putUserImage(imageId: succ.imageId)
                Log("프로필 이미지 등록 완료")
                return true
            case .failure:
                return false
                // profileImageError = .size
            }
        }
        
        return true
    }
    
    /// 백에서 이미지 삭제 & 연결 해제됨
    func deleteProfileImage() {
        Task {
            let deleteRes = await userNetwork.deleteUserImage()
            if let prevImageId {
                ImageCacheService.shared.removeCachedImage(imageId: prevImageId) /// 캐시에서 제거
                Log("프로필 이미지 캐시 제거")
            }
            Log("프로필 이미지 삭제 \(deleteRes ? "완료" : "실패")")
        }
    }
    
    func handleAlertConfirm() {
        switch alertType {
        case .DeleteProfileImage:
            deleteProfileImage()
        default:
            break
        }
    }
}
