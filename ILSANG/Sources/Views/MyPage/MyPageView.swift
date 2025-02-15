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
        NavigationView {
            VStack(spacing: 0) {
                header  // 타이틀 & 설정버튼
                content // 프로필 & 퀘스트/활동/내정보 컨텐츠
            }
            .padding(.horizontal, 20)
            .background(Color.background)
        }
        .task {
            // TODO:
            // 1) 초기화시 데이터 로딩하도록 수정
            // 2) 도전내역 등록했을 때, 리프레시했을 때 재호출하도록 수정
            await vm.fetchUser()
            await vm.fetchXpStats()
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
    }
    
    @ViewBuilder
    private var content: some View {
        // 개인 프로필
        MyPageProfile(nickName: vm.userData?.nickname, level: XpLevelCalculator.convertXPtoLv(xp: vm.userData?.xpPoint ?? 0))
        
        // 퀘스트/활동/뱃지 세그먼트
        MyPageTabView(selectedTab: $vm.selectedTab)
        
        // 퀘스트/활동/뱃지 리스트
        switch vm.selectedTab {
        case .quest:
            MyPageChallengeList(vm: vm)
        case .activity:
            MyPageActiveList(vm: vm)
        case .info:
            MyPageInfoView(xpPoint: vm.userData?.xpPoint, xpStats: vm.xpStats)
        }
    }
}

struct EmptyView: View {
    var title: String = ""
    
    var body: some View {
        Text(title)
            .font(.system(size: 17))
            .fontWeight(.medium)
            .foregroundColor(.gray400)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    MyPageView()
}
