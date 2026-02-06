//
//  SettingAlertView.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/27/24.
//

import SwiftUI

protocol AlertPresentable {
    var title: String { get }
    var subtitle: String? { get }
    var disagree: String { get }
    var agree: String { get }
    var titleColor: Color { get }
    var icon: UIImage? { get }
}

struct SettingAlertView<Content: View>: View {
    let alertType: AlertPresentable
    var onCancel: (() -> Void)? = nil
    var onConfirm: (() -> Void)? = nil
    let content: Content
    
    init(
        alertType: AlertPresentable,
        onCancel: (() -> Void)? = nil,
        onConfirm: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content = { EmptyView() }
    ) {
        self.alertType = alertType
        self.onCancel = onCancel
        self.onConfirm = onConfirm
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if let icon = alertType.icon {
                Image(uiImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(30)
                    .padding(.bottom, 6)
            }
            Text(alertType.title)
                .styledFont(.title2)
                .foregroundColor(alertType.titleColor)
                .multilineTextAlignment(.center)
            
            if let subtitle = alertType.subtitle {
                Text(subtitle)
                    .styledFont(.regular, size: 13, lineHeight: 20)
                    .lineSpacing(4)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.gray500)
                    .padding(.top, 6)
            }
            
            content
                .padding(.top, 6)
            
            HStack(spacing: 10) {
                if onCancel != nil {
                    Text(alertType.disagree)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray500)
                        .frame(maxWidth: .infinity, maxHeight: 42)
                        .background(Color.background)
                        .cornerRadius(12)
                        .onTapGesture { self.onCancel?() }
                }
                Text(alertType.agree)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, maxHeight: 42)
                    .background(.accent)
                    .cornerRadius(12)
                    .onTapGesture { self.onConfirm?() }
            }
            .padding(.top, 20)
        }
        .padding([.horizontal, .bottom], 16)
        .padding(.top, 28)
        .frame(width: 292)
        .background(.white)
        .cornerRadius(24)
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .background(.black.opacity(0.5))
    }
}

enum IllsangZoneAlertType: AlertPresentable {
    case illsangZoneSetWarning
    case illsangZoneSetSuccess
    case illsangZoneSetFailed
    case illsangZoneNotSelected
    case illsangZoneChangeNotAllowed
    var title: String {
        switch self {
        
        case .illsangZoneSetWarning: "한 번 선택한 일상존은 시즌 중에는\n변경이 불가합니다"
        case .illsangZoneSetSuccess: "일상존이 설정되었습니다"
        case .illsangZoneSetFailed: "일상존 변경에 실패했습니다"
        case .illsangZoneNotSelected: "일상존이 선택되지 않았어요"
        case .illsangZoneChangeNotAllowed: "내 일상존은 시즌 중에는\n변경이 불가합니다"
        }
    }
    var subtitle: String? {
        switch self {
        case .illsangZoneSetWarning: nil
        case .illsangZoneSetSuccess: "퀘스트를 수행하러 가 볼까요?"
        case .illsangZoneSetFailed: "다시 한번 시도해 주세요"
        case .illsangZoneNotSelected: "일상존을 선택하고 퀘스트를 수행하면\n기여도 포인트를 2배나 받을 수 있어요!"
        case .illsangZoneChangeNotAllowed: nil
        }
    }
    
    var disagree: String {
        switch self {
        case .illsangZoneSetWarning, .illsangZoneNotSelected:
            "취소"
        default:
            ""
        }
    }
    var agree: String {
        switch self {
        case .illsangZoneNotSelected:
            "일상존 선택하기"
        default:
            "확인"
        }
    }
    var titleColor: Color {
        switch self {
        case .illsangZoneSetWarning: .accentRed
        default: .black
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .illsangZoneSetFailed: .retry
        default: nil
        }
    }
}

enum AlertType: AlertPresentable {
    case CancleEditProfile
    case DeleteProfileImage
    case Logout
    case Withdrawal
    case ChallengeDelete
    case Comment(CommentAlertType)
    
    enum CommentAlertType: String {
        case errorTooLong
        case errorEmptyInput
        case errorInvalidCharacters
        case errorCreateTooFast
        case createFail
        case deleteFail

        var title: String {
            switch self {
            case .errorTooLong, .errorEmptyInput, .errorInvalidCharacters, .errorCreateTooFast:
                "댓글 입력"
            case .createFail:
                "댓글 등록 실패"
            case .deleteFail:
                "댓글 삭제 실패"
            }
        }
        var subtitle: String {
            switch self {
            case .errorTooLong: "300자 이하로 작성해 주세요."
            case .errorEmptyInput: "공백 제외 1자 이상 입력하세요."
            case .errorInvalidCharacters: "허용되지 않은 문자가 포함되어 있습니다."
            case .errorCreateTooFast: "1분 이내에는 댓글을 여러 번 작성하실 수 없습니다."
            case .createFail: "댓글을 등록할 수 없습니다"
            case .deleteFail: "댓글을 삭제할 수 없습니다"
            }
        }
    }
    
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
        case .ChallengeDelete:
            "챌린지를 삭제 할까요?"
        case .Comment(let type):
            type.title
        }
    }
    
    var subtitle: String? {
        switch self {
        case .CancleEditProfile:
            "변경을 완료하지 않으면\n프로필이 저장되지 않습니다."
        case .DeleteProfileImage:
            "기본 사진으로 변경됩니다."
        case .Withdrawal:
            "확인 시 일상 계정이 영구적으로 삭제되며,\n모든 데이터는 복구가 불가능합니다."
        case .ChallengeDelete:
            "삭제하면 복구가 불가합니다"
        case .Comment(let type):
            type.subtitle
        default: nil
        }
    }
    
    var disagree: String {
        switch self {
        case .CancleEditProfile, .DeleteProfileImage, .Withdrawal, .ChallengeDelete:
            "취소"
        case .Logout:
            "아니요"
        default: ""
        }
    }
    
    var agree: String {
        switch self {
        case .Logout:
            "예"
        default:
            "확인"
        }
    }
    
    var titleColor: Color {
        .black
    }
    
    var icon: UIImage? {
        nil
    }
}

#Preview {
    VStack{
        SettingAlertView(alertType: AlertType.Logout, onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: AlertType.CancleEditProfile,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: AlertType.DeleteProfileImage,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: AlertType.Withdrawal,onCancel: {print("Yes")},onConfirm: {print("NO")})
        SettingAlertView(alertType: AlertType.ChallengeDelete,onCancel: {print("Yes")},onConfirm: {print("NO")})
    }
}
