//
//  ProfileView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/29/25.
//


import SwiftUI

struct ProfileView: View {
    let profileImage: UIImage?
    let nickname: String
    let honor: UserTitle?
    var isWriter = false
    
    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: profileImage ?? .profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(nickname)
                        .styledFont(.semibold, size: 14, lineHeight: 14)
                    if isWriter {
                        Text("수행자")
                            .styledFont(.badge2)
                            .foregroundStyle(.primary500)
                            .padding(.horizontal, 6)
                            .frame(height: 20)
                            .roundedBackground(cornerRadius: 20, bgColor: .primary100)
                    }
                }
                
                if let honor {
                    HonorIconView(
                        honorTitle: honor.name,
                        grade: honor.grade,
                        imageSize: 20,
                        spacing: 4,
                        font: .badge1,
                        fgColor: .gray500
                    )
                }
            }
        }
        .foregroundStyle(.gray500)
    }
}

#Preview {
    ProfileView(
        profileImage: .profileCircle,
        nickname: "일상",
        honor: .init(
            titleHistoryId: 1,
            name: "김김김",
            grade: .legend,
            createdAt: .now
        ),
        isWriter: true
    )
}
