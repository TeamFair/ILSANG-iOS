//
//  MyPageProfile.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/23/24.
//

import SwiftUI

struct MyPageProfile: View {
    let nickName: String?
    let profileImage: UIImage?
    let profileImageId: String?
    let level: Int
    
    var body: some View {
        NavigationLink(destination: ProfileEditView(name: nickName ?? "", image: profileImage, imageId: profileImageId)) {
            HStack {
                // 프로필 이미지
                ProfileImageView(profileImage: profileImage, isEditMode: true)
                
                // 프로필 상세 - 닉네임, 레벨
                VStack (alignment: .leading, spacing: 4) {
                    Text(nickName ?? "일상")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.gray500)
                        .multilineTextAlignment(.leading)
                    
                    TagView(title: "Lv. \(level)", tagStyle: .levelStroke)
                }
                
                Spacer()
            }
        }
    }
}

struct ProfileImageView: View {
    var profileImage: UIImage?
    var isEditMode: Bool = false
    
    var body: some View {
        Group {
            //커스텀 이미지가 존재할 경우
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
            } else {
                //커스텀 이미지가 존재하지 않을 경우 - 기본 이미지
                Image("profile.circle")
                    .resizable()
            }
        }
        .frame(width: 57, height: 57)
        .clipShape(Circle())
        .overlay(alignment: .bottomTrailing) {
            if isEditMode {
                Image("profileEdit")
                    .padding(3)
                    .frame(width: 18, height: 18)
                    .background(.black)
                    .clipShape(.circle)
                    .offset(x: 0, y: 4)
            }
        }
        .frame(height: 61)
    }
}

#Preview {
    MyPageProfile(nickName: "닉네임", profileImage: .img0, profileImageId: "", level: 2)
}
