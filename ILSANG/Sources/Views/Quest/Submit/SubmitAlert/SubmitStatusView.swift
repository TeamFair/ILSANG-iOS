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
            case .inProgress:
                SubmitInprogressView()
            case .fail:
                SubmitFailView()
            case .retry:
                Image(.retry)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
            case .complete:
                EmptyView()
            }
            
            Text(status.title)
                .foregroundColor(.gray500)
                .font(.system(size: 17, weight: .bold))
                .padding(.top, 15)
                .padding(.bottom, 9)
            
            Text(status.subtitle)
                .foregroundColor(.gray400)
                .font(.system(size: 15, weight: .regular))
                .padding(.bottom, 4)
            
            PrimaryButton(title: "확인") {
                onConfirm()
            }
            .padding(16)
            .opacity(status == .inProgress ? 0 : 1)
        }
        .padding(.top, status == .inProgress ? 90 : 30)
        .frame(width: 260, height: 240)
        .roundedBackground(cornerRadius: 16)
    }
}

#Preview {
    ScrollView {
        SubmitStatusView(status: .inProgress, onConfirm: {})
        SubmitStatusView(status: .fail, onConfirm: {})
        SubmitStatusView(status: .retry, onConfirm: {})
        SubmitCompleteView(quest: .mockData, action: {})
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.secondary)
}
