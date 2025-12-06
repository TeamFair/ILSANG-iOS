//
//  ReportView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/6/25.
//

import SwiftUI

enum ReportType: CaseIterable {
    case abusive, advertisements, explicit, spam, other
    
    var title: String {
        switch self {
        case .abusive: "욕설/비방"
        case .advertisements: "광고/홍보"
        case .explicit: "음란/불법"
        case .spam: "스팸"
        case .other: "기타"
        }
    }
}

struct ReportView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedType: ReportType?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            NavigationTitleView(title: "신고하기", isSeparatorHidden: true) {
                dismiss()
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading, spacing: 0) {
                Text("신고 사유를 선택해 주세요")
                    .styledFont(.title1)
                    .foregroundStyle(.black)
                    .padding(.top, 36)
                    .padding(.bottom, 16)
                
                Text("신고하신 내용은 운영자가 24~48시간 내 검토 후 조치합니다. 허위 신고 시 서비스 이용이 제한될 수 있습니다.")
                    .styledFont(.subTitle1)
                    .foregroundStyle(.gray500)
                    .padding(.bottom, 36)
                
                ForEach(ReportType.allCases, id: \.title) { type in
                    VStack(alignment: .leading, spacing: 8) {
                        Button {
                            selectedType = type
                        } label: {
                            reportTypeLabel(type.title, isSelected: selectedType == type)
                        }
                    }
                }
                
                Spacer(minLength: 0)
                
                PrimaryButton(
                    title: "신고하기",
                    buttonAble: selectedType != nil,
                    action: {
                        // FIXME: 신고 API 호출
                    }
                )
            }
            .padding(.horizontal, 20)
        }
        .navigationBarBackButtonHidden()
    }
    
    private func reportTypeLabel(_ title: String, isSelected: Bool) -> some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 4)
                .inset(by: 0.5)
                .stroke(lineWidth: isSelected ? 0 : 1)
                .frame(20)
                .foregroundStyle(isSelected ? .clear : .gray200)
                .background(isSelected ? .primaryPurple : .clear)
                .clipShape(RoundedRectangle(cornerRadius: 4))
                .overlay {
                    if isSelected {
                        Image(.checkThin)
                            .renderingMode(.template)
                            .foregroundStyle(.white)
                    }
                }
                .frame(30)
            
            Text(title)
                .styledFont(.subTitle1)
                .foregroundStyle(.black)
        }
    }
}

#Preview {
    ReportView()
}
