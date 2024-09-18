//
//  OpenSourceInfoView.swift
//  ILSANG
//
//  Created by Kim Andrew on 9/3/24.
//

import SwiftUI

struct OpenSourceInfoView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "오픈소스 정보", isSeparatorHidden: true) {
                dismiss()
            }
            VStack {
                Text(openSource)
                    .font(Font.custom("Pretendard", size: 15))
                    .listRowBackground(Color.clear)
                
                Spacer()
            }
            .padding(.vertical, 15)
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
    }
}

#Preview {
    OpenSourceInfoView()
}
