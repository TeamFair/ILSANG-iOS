//
//  SettingView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/29/24.
//

import SwiftUI

struct SettingView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var logoutAlert = false
    @State var selectedSetting: Setting?
    
    private let settingList: [Setting] = [
        Setting(title: "고객센터", type: .navigate),
        Setting(title: "약관 및 정책", type: .navigate),
        Setting(title: "오픈소스 정보", type: .navigate),
        Setting(title: "현재 버전", type: .info("v\(Constants.appVersion ?? "1.0.0")")),
        Setting(title: "로그아웃", type: .alert),
        Setting(title: "회원 탈퇴", titleColor: .subRed, type: .navigate)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "설정", isSeparatorHidden: true) {
                dismiss()
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            List(settingList) { item in
                settingListItemView(item: item)
                    .onTapGesture {
                        if item.type == .navigate {
                            selectedSetting = item
                        } else if item.type == .alert {
                            logoutAlert.toggle()
                        }
                    }
                    .listRowSeparator(.hidden)
            }
            .listRowSpacing(2)
            .listStyle(.plain)
            .navigationDestination(item: $selectedSetting) { setting in
                switch setting.title {
                case "고객센터":
                    CustomerServiceView()
                case "약관 및 정책":
                    TermsAndPolicyView()
                case "오픈소스 정보":
                    OpenSourceInfoView()
                case "회원 탈퇴":
                    DeleteAccountView()
                default:
                    EmptyView()
                }
            }
        }
        .navigationBarBackButtonHidden()
        .overlay {
            if logoutAlert {
                SettingAlertView(
                    alertType: .Logout,
                    onCancel: { logoutAlert = false },
                    onConfirm: { logout() }
                )
            }
        }
    }
    
    private func settingListItemView(item: Setting) -> some View {
        HStack {
            Text(item.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(item.titleColor)
            Spacer()
            switch item.type {
            case .navigate:
                Image(systemName: "chevron.right")
                    .foregroundStyle(.gray300)
                    .fontWeight(.medium)
            case .alert:
                EmptyView()
            case .info(let string):
                Text(string)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray200)
                    .monospacedDigit()
            }
        }
        .frame(height: 36)
        .frame(maxWidth: .infinity)
        .background()
    }
    
    private func logout() {
        Task {
            let result = await LogoutNetwork().getLogout()
            switch result {
            case .success:
                UserService.shared.logout()
            case .failure(let err):
                Log("로그아웃 실패 \(err.localizedDescription)")
                logoutAlert = false
            }
        }
    }
}

#Preview {
    SettingView()
}
