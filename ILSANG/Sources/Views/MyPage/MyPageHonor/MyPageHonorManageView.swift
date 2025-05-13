//
//  MyPageHonorManageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 4/27/25.
//

import SwiftUI

struct MyPageHonorManageView: View {
    
    private let leadingTrailingColumnWidth: CGFloat = 50
    
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                NavigationTitleView(title: "내 칭호", isSeparatorHidden: true, background: .background) {
                    dismiss()
                }
                .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    MyPageHonorManageView()
}
