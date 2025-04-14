//
//  QuestDetailView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 11/23/24.
//

import SwiftUI

struct QuestDetailView: View {
    @State var vm: QuestDetailViewModel
    let action: () -> Void
    
    private let imageSpacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20

    private var contentWidth: CGFloat {
        (.screenWidth - (horizontalPadding * 2) - (imageSpacing * 2)) / 3
    }
    
    init(vm: QuestDetailViewModel, action: @escaping () -> Void) {
        self._vm = State(wrappedValue: vm)
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 0) {
            QuestDetailInfoView(quest: vm.quest)
            
            HStack {
                if vm.quest.missionType == .image {
                    QuestDetailApprovalImageView(
                        images: vm.quest.challengeImages,
                        showCount: vm.quest.isRepeatQuest ? 1 : 3,
                        imageWidth: contentWidth,
                        imageSpacing: imageSpacing,
                        isLoading: vm.isLoading,
                        onTap: { [weak vm] selectedImage in
                            vm?.onImageTapped(image: selectedImage)
                        }
                    )
                }
                
                if vm.quest.isRepeatQuest {
                    QuestDetailRepeatRankView(rank: vm.quest.customerRank, contentWidth: contentWidth)
                }
            }
            .padding(.vertical, vm.quest.isRepeatQuest || vm.quest.missionType == .image ? 24 : 0)
        
            QuestDetailStatView(quest: vm.quest)
            
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
                            .frame(maxWidth: .infinity)
                            .overlay(alignment: .trailing) {
                                Button {
                                    vm.toggleFavorite()
                                } label: {
                                    Image(.star)
                                        .renderingMode(.template)
                                        .foregroundStyle(vm.quest.favoriteYn ? .primary300 : .gray100)
                                }
                                .padding(.bottom, 2)
                            }
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
    QuestDetailView(vm: QuestDetailViewModel(quest: .mockData, questNetwork: QuestNetwork(), onUpdate: {_ in }), action: { })
        .frame(height: 684)
}


#Preview {
    QuestDetailView(vm: QuestDetailViewModel(quest: .mockRepeatData, questNetwork: QuestNetwork(), onUpdate: {_ in }), action: { })
        .frame(height: 684)
}
