//
//  DetailQuestview.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/31/24.
//

import SwiftUI

struct DetailQuestview: View {
    
    @Environment(\.dismiss) var dismiss
    @StateObject var vm: MypageViewModel = MypageViewModel(userNetwork: UserNetwork(),xpNetwork: XPNetwork(), questNetwork: ChallengeNetwork(), imageNetwork: ImageNetwork())
    
    @State private var missionImage: UIImage? = nil
    
    let ChallengeData : Challenge
    
    var body: some View {
        
        NavigationTitleView(title: "챌린지 정보") {
            dismiss()
        }
        .overlay(alignment: .trailing) {
                Button {
                    vm.challengeDelet.toggle()
                } label: {
                    DeleteButton()
                }
        }
        .background(Color.white)
        
        ZStack {
            if let missionImage = missionImage {
                Image(uiImage: missionImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ErrorView(title: "챌린지 정보를 불러오지 못했어요", subTitle: "챌린지 정보를 불러오는 데 실패했어요.\n인터넷 연결 상태 확인 후 다시 시도해주세요."){
                    Task {
                        missionImage = await vm.getImage(imageId: ChallengeData.receiptImageId)
                    }
                }
                    .background(Color.background)
            }
            
            if missionImage != nil {
                VStack {
                    Spacer()
                    
                    HStack() {
                        VStack (alignment: .leading) {
                            Text(ChallengeData.quest?.missions.first?.title ?? "")
                                .font(.headline)
                                .padding(.bottom, 1)
                            
                            Text("좋아요 \(ChallengeData.likeCnt)개")
                                .font(.subheadline)
                                .foregroundColor(.gray500)
                        }
                        
                        Spacer()
                        
                        VStack{
                            Text(ChallengeData.createdAt.timeAgoCreatedAt())
                                .font(.subheadline)
                                .foregroundColor(.gray400)
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: 80)
                    .background(Color(.gray300))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                }
            } 
        }
        .overlay {
            if vm.challengeDelet {
                SettingAlertView(
                    alertType: .QuestDelete,
                    onCancel: { vm.challengeDelet = false },
                    onConfirm: {
                        Task {
                            if await vm.updateQuestStatus(challengeId: ChallengeData.challengeId,ImageId: ChallengeData.receiptImageId) {
                                vm.challengeDelet = false
                            }
                        }
                    }
                )
            }
        }
        .task {
            missionImage = await vm.getImage(imageId: ChallengeData.receiptImageId)
        }
        .navigationBarBackButtonHidden()
    }
}
