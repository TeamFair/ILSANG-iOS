//
//  SubmitComponent.swift
//  ILSANG
//
//  Created by Lee Jinhee on 10/22/24.
//

import SwiftUI

/// 제출 진행 중 & 제출 실패 상태 화면
struct SubmitStatusView: View {
    let status: SubmitStatus
    var onConfirm: () -> ()
    
    var body: some View {
        VStack(spacing: 0) {
            switch status {
            case .submit:
                SubmitView()
            case .fail:
                SubmitFailView()
            default:
                IconView(iconWidth: status.iconWidth, size: .medium, icon: status.icon, color: status.color)
            }
            
            Text(status.title)
                .foregroundColor(.gray500)
                .font(.system(size: 17, weight: .bold))
                .padding(.top, 15)
                .padding(.bottom, 9)
            
            HStack(spacing: 0) {
                Text(status.subtitle)
                    .foregroundColor(.gray400)
                    .font(.system(size: 15, weight: .regular))
                Text(status.emoticon)
                    .font(.system(size: 12))
            }
            .padding(.bottom, 4)
            
            PrimaryButton(title: "확인") {
                onConfirm()
            }
            .padding(16)
            .opacity(status == .submit ? 0 : 1)
        }
        .padding(.top, status == .submit ? 90 : 30)
        .frame(width: 260, height: 240)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .foregroundStyle(.white)
        )
    }
}

#Preview {
    VStack {
        SubmitStatusView(status: .submit, onConfirm: {})
        SubmitStatusView(status: .fail, onConfirm: {})
        SubmitCompleteView(quest: .mockData, action: {})
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondary)
}
