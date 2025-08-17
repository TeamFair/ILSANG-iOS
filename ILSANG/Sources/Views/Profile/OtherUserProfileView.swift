//
//  OtherUserProfileView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/8/25.
//

import SwiftUI

struct OtherUserProfileView: View {
    @StateObject var vm: OtherUserProfileViewModel
    @Environment(\.dismiss) var dismiss
    
    init(customerId: String) {
        _vm = StateObject(wrappedValue: OtherUserProfileViewModel(customerId: customerId, userNetwork: UserNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork(), pointNetwork: PointNetwork()))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header  // 타이틀
            content // 프로필 & 능력별 포인트 & 도전내역 목록
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .task {
            await vm.loadInitialData()
        }
    }
    
    private var header: some View {
        NavigationTitleView(title: "프로필 정보", isSeparatorHidden: false) {
            dismiss()
        }
        .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
    }
    
    private var content: some View {
        ScrollView {
            VStack(spacing: 24) {
                userProfileSection
                challengeSection
            }
            .padding(.top, 16)
            .padding(.horizontal, 20)
        }
    }
    
    private var userProfileSection: some View {
        HStack(spacing: 16) {
            // 프로필 이미지
            ProfileImageView(profileImage: vm.userProfileIamge, imageSize: 57)
                .overlay {
                    TagView(title: "LV.\(vm.currentLv)", tagStyle: .levelStroke)
                        .offset(y: 24)
                }
            
            // 프로필 상세 - 닉네임, 레벨
            VStack(alignment: .leading, spacing: 8) {
                Text(vm.userData?.nickname ?? "일상")
                    .styledFont(.heading2)
                    .foregroundStyle(.gray500)
                    .multilineTextAlignment(.leading)
                
                if let honor = vm.userData?.title, let grade = HonorGrade(rawValue: honor.type)  {
                    HonorIconView(
                        honorTitle: honor.name,
                        grade: grade,
                        imageSize: 20,
                        spacing: 4,
                        font: .badge1,
                        fgColor: .gray500
                    )
                }
                                    
                HStack(alignment: .center, spacing: 6) {
                    ProgressBar(progress: vm.progress)
                        .frame(height: 8)

                    Text("\(vm.userData?.xpPoint ?? 0)XP")
                        .styledFont(.bold, size: 13, lineHeight: 13, tracking: 0)
                        .foregroundStyle(.primaryPurple)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 18)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
        )
    }
    
    private var challengeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("수행한 챌린지")
                .styledFont(.heading2)
                .foregroundColor(.gray400)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 4)
            
            OtherUserChallengeList(vm: vm)
        }
    }
}

#Preview {
    OtherUserProfileView(customerId: "IUS0000000")
}

