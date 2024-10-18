//
//  MyPageQuestList.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/22/24.
//

import SwiftUI
//MARK: 색상 폰트 변경 요청
struct MyPageChallengeList: View {
    
    @ObservedObject var vm: MypageViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("수행한 챌린지")
                    .font(.system(size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.gray400)
                
                Spacer()
            }
            // Data List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(vm.challengeList, id: \.challengeId) { challenge in
                        NavigationLink(destination: ChallengeDetailView(vm: vm, challengeData: challenge)) {
                            ListStruct(title: challenge.missionTitle ?? "챌린지명", detail: challenge.createdAt.timeAgoCreatedAt(), point: nil)
                        }
                    }
                }
            }
            .refreshable {
                await vm.getChallenges(page: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay {
            if vm.challengeList.isEmpty {
                EmptyView(title: "수행한 퀘스트가 없어요!")
            }
        }
    }
}

struct ListStruct: View {
    
    let title: String
    let detail: String
    let point: Int?
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(.black)
                Text(detail)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray500)
            }
            
            Spacer()
            
            if let point = point {
                Text("\(point > 0 ? "+\(point)" : "\(point)")XP")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(Color.accentColor)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .foregroundColor(.white)
        )
    }
}
