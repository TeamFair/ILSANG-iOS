//
//  OpenSourceInfoView.swift
//  ILSANG
//
//  Created by Kim Andrew on 9/3/24.
//

import SwiftUI

struct OpenSourceInfoView: View {
    
    var body: some View {
        StandardScreenView(title: "오픈소스 정보") {
            Text(openSource)
                .styledFont(.regular, size: 16, lineHeight: 18)
                .padding(16)
                .foregroundStyle(.gray500)
                .frame(maxWidth: .infinity)
                .background(Color.white)
        }
    }
}

#Preview {
    OpenSourceInfoView()
}
