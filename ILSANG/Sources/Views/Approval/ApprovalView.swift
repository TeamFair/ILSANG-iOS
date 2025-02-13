//
//  ApprovalView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct ApprovalView: View {
    @State var vm = ApprovalViewModel(
        emojiNetwork: EmojiNetwork(),
        challengeNetwork: ChallengeNetwork()
    )
    
    var body: some View {
        VStack(spacing: 0) {
            switch vm.viewStatus {
            case .error:
                networkErrorView
            case .loading:
                ProgressView()
            case .loaded:
                itemView
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.background)
        .task {
            await vm.loadInitialData()
        }
        .overlay { reportAlertView }
    }
    
    /// 퀘스트 타이틀  + 퀘스트 인증 이미지
    @ViewBuilder
    private var itemView: some View {
        if vm.itemList.isEmpty {
            emptyView
        } else {
            imageListView
        }
    }
    
    private var imageListView: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(Array(vm.itemList.enumerated()), id: \.element.id) { idx, item in
                    ApprovalItemView(
                        item: item,
                        width: .screenWidth - 40,
                        height: ((.screenWidth-40) / 5) * 4,
                        padding: 20,
                        onLike: { vm.onLike(for: idx) },
                        onHate: { vm.onHate(for: idx) }
                    )
                    .overlay(alignment: .topTrailing) {
                        trailingButton(for: item)
                    }
                }
                
                if let manager = vm.paginationManager, manager.canLoadMoreData() {
                    ProgressView()
                        .task { await vm.loadMoreData() }
                }
            }
            .padding(.top, 47)
            .padding(.bottom, 72)
        }
        .refreshable {
            await vm.loadInitialData()
        }
    }
    
    private func trailingButton(for item: ApprovalViewModelItem) -> some View {
        Menu {
            ShareLink(item: photo, preview: SharePreview(photo.caption, image: photo.image)) {
                Label("공유하기", image: "share")
            }
            .onAppear {
                vm.selectedChallenge = item
            }
            
            Button {
                vm.selectedChallenge = item
                vm.showReportAlert = true
            } label: {
                Label("신고하기", image: "syren")
            }
            .foregroundStyle(.gray500)
        } label: {
            Image(.moreVertical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray500)
                .frame(height: 35)
        }
        .padding(20)
    }
    
    @ViewBuilder
    private var reportAlertView: some View {
        if vm.showReportAlert {
            SettingAlertView(
                alertType: .Report,
                onCancel: { vm.dismissReportAlert() },
                onConfirm: { Task { await vm.confirmReport() } }
            )
        }
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await vm.loadInitialData() }
        }
    }
    
    private var emptyView: some View {
        ErrorView(
            title: "인증할 이미지를 불러오지 못했어요",
            subTitle: "다음에 다시 시도해주세요"
        ) {
            Task { await vm.loadInitialData() }
        }
    }
    
    // MARK: - 챌린지 이미지 공유하기
    private var photo: TransferableUIImage {
        return .init(uiimage: shareChallengeImage, caption: "일상 챌린지 공유하기")
    }
    
    private var shareChallengeImage: UIImage {
        let renderer = ImageRenderer(
            content: ApprovalItemContentView(
                item: vm.selectedChallenge ?? .failedData,
                width: .screenWidth-40,
                height: ((.screenWidth-40) / 5) * 4
            )
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.white)
            )
        )
        
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}

#Preview {
    ApprovalView()
}
