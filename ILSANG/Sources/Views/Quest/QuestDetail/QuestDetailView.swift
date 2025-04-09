//
//  QuestDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/23/24.
//

import SwiftUI

struct QuestDetailView: View {
    @StateObject var vm: QuestDetailViewModel
    var quest: QuestViewModelItem
    let action: () -> Void
    
    private let imageSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20

    private var contentWidth: CGFloat {
        (.screenWidth - (horizontalPadding * 2) - (imageSpacing * 2)) / 3
    }
    
    init(vm: QuestDetailViewModel, action: @escaping () -> Void) {
        self._vm = StateObject(wrappedValue: vm)
        self.quest = vm.quest
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            QuestDetailInfoView(quest: quest)
            
            HStack {
                if quest.missionType == .image {
                    QuestDetailApprovalImageView(
                        images: vm.quest.challengeImages,
                        showCount: quest.isRepeatQuest ? 1 : 3,
                        imageWidth: contentWidth,
                        imageSpacing: imageSpacing,
                        isLoading: vm.isLoading,
                        onTap: { [weak vm] selectedImage in
                            vm?.onImageTapped(image: selectedImage)
                        }
                    )
                }
                
                if quest.isRepeatQuest {
                    QuestDetailRepeatRankView(rank: quest.customerRank, contentWidth: contentWidth)
                }
            }
            .padding(.vertical, quest.isRepeatQuest || quest.missionType == .image ? 24 : 0)
        
            QuestDetailStatView(quest: quest)
            
            Spacer(minLength: 0)
            
            Text(vm.approvalDescription)
                .font(.system(size: 14, weight: .regular))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.bottom, CGFloat.isSmallDevice ? 8 : 16)
        }
        .task {
            await vm.fetchQuestDetail()
        }
        .sheet(isPresented: $vm.showImageSheetView, content: {
            ImageFullScreenView(image: vm.selectedImage) {
                vm.showImageSheetView.toggle()
            }
        })
        .scrollIndicators(.never)
        .foregroundStyle(.gray500)
        .safeAreaInset(
            edge: .top,
            content: {
                VStack(spacing: 0) {
                    RoundedRectangle(cornerRadius: 2)
                        .frame(width: 30, height: 4)
                        .foregroundStyle(.gray100)
                        .padding(.top, 8)
                        .padding(.bottom, 14)
                    
                    Text("퀘스트 정보")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.gray500)
                        .padding(.bottom, 12)
                }
            })
        .safeAreaInset(edge: .bottom) {
            PrimaryButton(title: "퀘스트 인증하기") {
                action()
            }
            .padding(.bottom, 8)
        }
        .padding(.horizontal, 20)
    }
}

#Preview {
    QuestDetailView(vm: QuestDetailViewModel(quest: .mockData, questNetwork: QuestNetwork()), action: { })
        .frame(height: 684)
}


#Preview {
    QuestDetailView(vm: QuestDetailViewModel(quest: .mockRepeatData, questNetwork: QuestNetwork()), action: { })
        .frame(height: 684)
}
