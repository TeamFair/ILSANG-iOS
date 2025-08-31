//
//  ErrorView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/2/24.
//

import SwiftUI

/// emoticon 사용할 경우 subtitle 텍스트 끝에 띄어쓰기를 추가해야 공백이 생깁니다.
/// 버튼을 포함하고 액션을 추가하려면, buttonAction 파라미터를 사용하여 정의합니다.
struct ErrorView: View {
    var systemImageName: String? = nil
    let title: String
    let subTitle: String
    var emoticon: String? = nil
    var showButton: Bool = true
    var buttonTitle: String = "다시 시도"
    var buttonAction: (() -> ())? = nil
    
    var body: some View {
        VStack(spacing: 0) {
            if let systemImageName {
                Image(systemName: systemImageName)
                    .foregroundColor(.gray300)
                    .font(.system(size: 60, weight: .regular))
                    .padding(.bottom, 28)
            }
            
            Text(title)
                .font(.system(size: 21, weight: .bold))
                .foregroundColor(.gray500)
                .padding(.bottom, 16)
            
            Group {
                Text(subTitle)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.gray400)
                + Text(emoticon ?? "")
                    .font(.system(size: 14))
                    .baselineOffset(2)
            }
            .multilineTextAlignment(.center)
            .lineSpacing(5)
            
            PrimaryButton(title: buttonTitle) {
                buttonAction?()
            }
            .frame(width: 152)
            .padding(.top, 46)
            .opacity(showButton ? 1 : 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    ErrorView(
        systemImageName: "wifi.exclamationmark",
        title: "네트워크 연결 상태를 확인해주세요",
        subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
        emoticon: "🥲"
    ) {
        print("Test")
    }
}
