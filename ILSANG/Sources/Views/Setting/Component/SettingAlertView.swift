//
//  SettingAlertView.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/27/24.
//

import SwiftUI

struct SettingAlertView: View {
    
    let alertType: AlertType
    var onCancel: (() -> Void?)? = nil
    var onConfirm: (() -> Void?)? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            Text(alertType.title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
            
            if let subtitle = alertType.subtitle {
                Text(subtitle)
                    .font(.system(size: 13))
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray500)
                    .padding(.top, 6)
            }
            
            HStack(spacing: 10) {
                Text(alertType.disagree)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.gray500)
                    .frame(maxWidth: 140, maxHeight: 50)
                    .background(Color.background)
                    .cornerRadius(12)
                    .onTapGesture { self.onCancel?() }
                
                Text(alertType.agree)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: 140, maxHeight: 50)
                    .background(.accent)
                    .cornerRadius(12)
                    .onTapGesture { self.onConfirm?() }
            }
            .padding(.top, 20)
        }
        .padding([.horizontal, .bottom], 16)
        .padding(.top, 28)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.black.opacity(0.5))
    }
}

enum AlertType {
    case CancleEditProfile
    case DeleteProfileImage
    case Logout
    case Withdrawal
    case Report
    case ChallengeDelete
    
    var title: String {
        switch self {
        case .CancleEditProfile:
            "프로필 변경을 취소할까요?"
        case .DeleteProfileImage:
            "프로필 사진을 삭제하시겠습니까?"
        case .Logout:
            "로그아웃 하시겠어요?"
        case .Withdrawal:
            "정말 탈퇴하시겠어요?"
        case .Report:
            "신고하시겠습니까?"
        case .ChallengeDelete:
            "챌린지를 삭제 할까요?"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .CancleEditProfile:
            "변경을 완료하지 않으면\n프로필이 저장되지 않습니다."
        case .DeleteProfileImage:
            "기본 사진으로 변경됩니다."
        case .Logout:
            nil
        case .Withdrawal:
            "확인 시 일상 계정이 영구적으로 삭제되며,\n모든 데이터는 복구가 불가능합니다."
        case .Report:
            "확인 후 빠른 시일 내 조치하도록 하겠습니다"
        case .ChallengeDelete:
            "삭제하면 복구가 불가합니다"
        }
    }
    
    var disagree: String {
        switch self {
        case .CancleEditProfile, .DeleteProfileImage, .Withdrawal, .Report,.ChallengeDelete:
            "취소"
        case .Logout:
            "아니요"
        }
    }
    
    var agree: String {
        switch self {
        case .CancleEditProfile, .DeleteProfileImage, .Withdrawal,.Report,.ChallengeDelete:
            "확인"
        case .Logout:
            "예"
        }
    }
}

#Preview {
    VStack{
        SettingAlertView(alertType: .Logout,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: .CancleEditProfile,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: .DeleteProfileImage,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: .Withdrawal,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: .ChallengeDelete,onCancel: {print("Yes")},onConfirm: {print("NO")})
    }
}
