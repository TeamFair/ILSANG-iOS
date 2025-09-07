//
//  MyPageProfile.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/23/24.
//

import SwiftUI

struct MyPageProfile: View {
    @EnvironmentObject var dependencies: AppDependencies
    let nickName: String?
    let profileImage: UIImage?
    let profileImageId: String?
    let level: Int
    let progress: CGFloat
    let honorTitle: String?
    let honorType: HonorGrade?
    
    var body: some View {
        VStack(spacing: 8) {
            profileInfoView
            honorIconView
        }
    }
    
    private var profileInfoView: some View {
        NavigationLink(destination: ProfileEditView(name: nickName ?? "", image: profileImage, imageId: profileImageId)) {
            VStack(spacing: 16) {
                ZStack {
                    ProgressCircleView(progress: progress, size: .init(width: 116, height: 116))
                    ProfileImageView(profileImage: profileImage, imageSize: 86, isEditMode: true)
                }
                .overlay(alignment: .bottom) {
                    TagView(title: "Lv. \(level)", tagStyle: .levelStrokeBig)
                }
                
                HStack(spacing: 8) {
                    Text(nickName ?? "일상")
                        .styledFont(.bold, size: 16, lineHeight: 18)
                        .foregroundStyle(.gray500)
                        .multilineTextAlignment(.leading)
                    Image("profileEdit")
                        .padding(3)
                        .frame(width: 18, height: 18)
                        .background(.black)
                        .clipShape(.circle)
                }
            }
        }
    }
    
    private var honorIconView: some View {
        NavigationLink {
            MyPageHonorManageView(dependencies: dependencies)
        } label: {
            HonorIconView(
                honorTitle: honorTitle ?? "칭호를 선택해주세요",
                grade: honorType ?? .standard,
                imageSize: 20,
                spacing: 4,
                font: .badge1,
                fgColor: .gray500
            )
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background(
                Capsule()
                    .strokeBorder(
                        .gray100,
                        style: StrokeStyle(lineWidth: 1)
                    )
            )
        }
    }
}

struct ProfileImageView: View {
    var profileImage: UIImage?
    let imageSize: CGFloat
    var isEditMode: Bool = false
    
    var body: some View {
        Group {
            // 프로필 이미지가 존재할 경우
            if let profileImage = profileImage {
                Image(uiImage: profileImage)
                    .resizable()
            } else {
                //프로필 이미지가 존재하지 않을 경우 - 기본 이미지
                Image("profile.circle")
                    .resizable()
            }
        }
        .frame(width: imageSize, height: imageSize)
        .clipShape(Circle())
    }
}

#Preview {
    MyPageProfile(nickName: "닉네임", profileImage: .img0, profileImageId: "", level: 2, progress: 0.5, honorTitle: "세상을 움직이는 자", honorType: .legend)
}
