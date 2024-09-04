//
//  MyPageView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct MyPageView: View {
    
    @State var activeTestData: [XPContent] = [
            XPContent(recordId: 1, title: "Mission Accomplished", xpPoint: 100, createDate: "2024-06-21"),
            XPContent(recordId: 2, title: "Daily Login", xpPoint: 50, createDate: "2024-06-22"),
            XPContent(recordId: 3, title: "Quest Completed", xpPoint: 150, createDate: "2024-06-23")
        ]
    
    @StateObject var vm: MypageViewModel = MypageViewModel(userNetwork: UserNetwork(),xpNetwork: XPNetwork(), challengeNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork())
    
    @State var segmentSelect = 0
    @State private var isSettingsViewActive = false
    
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 프로필 제목
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
                
                // 개인 프로필
                MyPageProfile()
                
                // 퀘스트/활동/뱃지 세그먼트
                MyPageSegment(selectedIndex: $segmentSelect)
                
                // 퀘스트/활동/뱃지 리스트
                switch segmentSelect {
                case 0:
                    if let questData = vm.challengeList, !questData.isEmpty {
                        MyPageQuestList(questData: .constant(questData))
                    } else {
                        emptyView()
                    }
                case 1:
                    if let activeData = vm.questXp, !activeData.isEmpty {
                        MyPageActiveList(activeData: .constant(activeData))
                    } else {
                        emptyView()
                    }
                case 2:
                    emptyView()
                    
                    // 뱃지 구현후 적용
                    //MyPageBadgeList(badgeData: .constant([]))
                default:
                    emptyView()
                }
            }
            .padding(.horizontal, 20)
            .background(Color.background)
        }
        .task {
            await vm.getData()
        }
    }
}

struct emptyView: View {
    var body: some View {
        VStack {
            Text("Coming Soon!")
                .font(.system(size: 17))
                .fontWeight(.medium)
                .foregroundColor(.gray400)
                .multilineTextAlignment(.center)
                .refreshable {
                    // 데이터 리프레시
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
