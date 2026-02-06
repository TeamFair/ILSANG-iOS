//
//  ReportPopup.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/6/25.
//

import SwiftUI

struct ReportPopupView: View {
    var onClose: () -> Void
    let type: ReportPopupType
    
    enum ReportPopupType {
        case reported
        case succ
        case fail
        
        var title: String {
            switch self {
            case .reported:
                "이미 신고하신 콘텐츠입니다\n현재 검토 중에 있습니다"
            case .succ:
                "신고가 접수되었습니다\n감사합니다"
            case .fail:
                "신고를 접수할 수 없습니다"
            }
        }
        
        var image: ImageResource {
            switch self {
            case .succ, .reported: .syrenFill
            case .fail: .retry
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("신고하기")
                    .styledFont(.heading2)
                    .foregroundStyle(.black)
                Spacer(minLength: 0)
                Button {
                  onClose()
                } label: {
                    XmarkButton(color: .gray500)
                }
            }
            .padding(.bottom, 54)
            
            Image(type.image)
                .padding(.bottom, 16)

            Text(type.title)
                .styledFont(.heading3)
                .foregroundStyle(.black)
                .multilineTextAlignment(.center)
                .padding(.bottom, 66)

            PrimaryButton(title: "확인") {
                onClose()
            }
        }
        .padding(16)
        .roundedBackground(cornerRadius: 12)
    }
}

#Preview {
    ScrollView {
        ReportPopupView(onClose: { }, type: .succ)
        ReportPopupView(onClose: { }, type: .fail)
        ReportPopupView(onClose: { }, type: .reported)
    }
    .background(.black)
}
