//
//  MyPageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MyPageView: View {
    
    @StateObject var vm: MyPageViewModel = MyPageViewModel(userNetwork: UserNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork(), xpNetwork: XPNetwork())
    
    var body: some View {
        VStack(spacing: 0) {
            header  // 타이틀 & 설정 버튼
            content // 프로필 & 퀘스트/활동/내정보 컨텐츠
        }
        .background(Color.background)
        .task {
            // TODO:
            // 1) 초기화시 데이터 로딩하도록 수정
            // 2) 도전내역 등록했을 때, 리프레시했을 때 재호출하도록 수정
            await vm.fetchUser()
            await vm.fetchXpStats()
            
            // 도전내역, 활동로그 불러오기
            await vm.loadDataIfNeeded()
        }
    }
    
    private var header: some View {
        HStack {
            Text("내 프로필")
                .font(.system(size: 21))
                .fontWeight(.bold)
                .foregroundColor(.gray500)
            Spacer()
            NavigationLink(destination: SettingView()) {
                Image("Setting")
                    .foregroundColor(.gray500)
            }
        }
        .frame(height: 50)
        .padding(.bottom, 5)
        .padding(.horizontal, 20)
    }
    
    @ViewBuilder
    private var content: some View {
        ScrollView {
            VStack(spacing: 0) {
                // 프로필
                MyPageProfile(
                    nickName: vm.userData?.nickname,
                    profileImage: vm.userProfileImage,
                    profileImageId: vm.userData?.profileImage,
                    level: vm.xpStatus.currentLv,
                    progress: vm.xpStatus.progress,
                    honorTitle: vm.honorTitle,
                    honorType: vm.honorType
                )
                .padding(.bottom, 36)
                
                // 퀘스트/뱃지 세그먼트
                MyPageTabView(selectedTab: $vm.selectedTab)
                    .padding(.bottom, 16)
                
                // 퀘스트/뱃지 컨텐츠
                switch vm.selectedTab {
                case .quest:
                    MyPageChallengeList(vm: vm)
                case .info:                    
                    MyPageInfoView(xpPoint: vm.userData?.xpPoint, xpStats: vm.xpStats, honorTitle: vm.honorTitle)
                }
            }
            .padding(.bottom, 72)
            .padding(.horizontal, 20)
        }
        .scrollIndicators(vm.selectedTab == .quest ? .visible : .never)
        .refreshable {
            switch vm.selectedTab {
            case .quest:
                await vm.challengePaginationManager.loadData(isRefreshing: true)
            case .info:
                await vm.fetchUser()
                await vm.fetchXpStats()
            }
        }
    }
}

struct EmptyView: View {
    var title: String = ""
    
    var body: some View {
        Text(title)
            .styledFont(.semibold, size: 23, lineHeight: 33)
            .foregroundColor(.gray300)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView()
}
