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
        Setting(title: "자주 물어보는 질문", type: .navigate),
        Setting(title: "약관 및 정책", type: .navigate),
        Setting(title: "오픈소스 정보", type: .navigate),
        Setting(title: "현재 버전", type: .info("v\(Constants.appVersion ?? "1.0.0")")),
        Setting(title: "로그아웃", type: .alert),
        Setting(title: "회원 탈퇴", titleColor: .subRed, type: .navigate)
    ]
    
    var body: some View {
        StandardScreenView(title: "설정") {
            LazyVStack(spacing: 0) {
                ForEach(settingList, id: \.title) { item in
                    SettingItemView(item: item, action: {
                        if item.type == .navigate {
                            selectedSetting = item
                        } else if item.type == .alert {
                            logoutAlert.toggle()
                        }
                    })
                }
            }
            .background(.white)
            .navigationDestination(item: $selectedSetting) { setting in
                switch setting.title {
                case "고객센터":
                    CustomerServiceView()
                case "자주 물어보는 질문":
                    FAQView()
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
