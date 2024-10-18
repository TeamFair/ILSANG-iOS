//
//  ApprovalView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/20/24.
//

import SwiftUI

struct ApprovalView: View {
    @StateObject var vm = ApprovalViewModel(
        emojiNetwork: EmojiNetwork(),
        challengeNetwork: ChallengeNetwork()
    )
        
    private let viewWidth = UIScreen.main.bounds.width - 40
    private let viewHeight = UIScreen.main.bounds.height
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                switch vm.viewStatus {
                case .error:
                    networkErrorView
                case .loading:
                    ProgressView()
                case .loaded:
                    itemView
                    recommendButtons
                }
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    switch vm.viewStatus {
                    case .error, .loading:
                        Color.background
                    case .loaded:
                        if !vm.itemList.isEmpty {
                            Image(uiImage: vm.itemList[vm.currentIdx].image ?? .logo)
                                .resizable()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .ignoresSafeArea()
                                .scaledToFill()
                                .scaleEffect(1.4)
                                .blur(radius: 30, opaque: true)
                                .background(Color.black.opacity(0.2))
                        }
                    }
                }
            )
            .ignoresSafeArea()
            
            if vm.showReportAlert {
                SettingAlertView(
                    alertType: .Report,
                    onCancel: {
                        vm.showReportAlert = false
                    }, onConfirm: {
                        Task {
                            await vm.reportChallenge()
                            vm.showReportAlert = false
                        }
                    }
                )
            }
        }
        .task {
            await vm.getData()
        }
    }
    
    /// 퀘스트 타이틀  + 퀘스트 인증 이미지
    private var itemView: some View {
        Group {
            if !vm.itemList.isEmpty {
                VStack(spacing: 14) {
                    itemTitleView
                    imageListView
                }
                .shadow(color: .shadowFF.opacity(0.25), radius: 20, x: 0, y: 12)
            }
        }
    }
    
    private var itemTitleView: some View {
        Text(vm.itemList[vm.currentIdx].title)
            .font(.system(size: 16, weight: .bold))
            .foregroundStyle(.gray500)
            .frame(height: 45)
            .frame(width: viewWidth - 20, alignment: .leading)
            .padding(.leading, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .foregroundStyle(.white)
            )
            .zIndex(1)
    }
    
    private var imageListView: some View {
        ZStack(alignment: .bottom) {
            ForEach(vm.itemList.reversed(), id: \.id) { item in
                let idx = vm.itemList.firstIndex { $0.id == item.id }
                let diff: Int = abs(idx! - vm.currentIdx)
                imageView(for: item, diff: diff)
            }
            .gesture(dragGesture)
        }
        .mask(alignment: .top) {
            maskArea
        }
        .overlay(alignment: .topTrailing) {
            Button {
                vm.showReportAlert = true
            } label: {
                Image(systemName: "ellipsis")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .frame(width: 44, height: 44)
                    .foregroundStyle(.gray100)
            }
            .padding(.trailing, 10)
        }
    }
    
    private func imageView(for item: ApprovalViewModelItem, diff: Int) -> some View {
        ApprovalImageView(
            image: item.image ?? .logo,
            width: abs(viewWidth - 40 * CGFloat(diff)),
            height: (viewHeight / 2) - CGFloat(diff) * 26,
            nickname: item.nickname,
            time: item.time,
            showProfile: diff <= 1
        )
        .opacity(vm.calculateOpacity(itemIndex: vm.itemList.firstIndex { $0.id == item.id }!))
        .offset(y: diff <= 2 ? CGFloat(diff) * 26 : 50)
        .offset(y: item.offset)
    }
        
    /// 이미지 스크롤 시 상단 마스크
    private var maskArea: some View {
        VStack(spacing: 0) {
            LinearGradient(
                stops: [
                    Gradient.Stop(color: .clear, location: .zero),
                    Gradient.Stop(color: .black, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 16)
            Color.black
        }
        .padding(.top, -20)
        .padding(.bottom, -60)
    }
    
    private var recommendButtons: some View {
        HStack(spacing: 78) {
            Button {
                Task { await vm.updateEmojiWithPrev(emojiType: .hate) }
            } label: {
                emojiButton(imageName: "hand.thumbsdown.fill", active: vm.emoji?.isHate ?? false)
            }
            Button {
                Task { await vm.updateEmojiWithPrev(emojiType: .like) }
            } label: {
                emojiButton(imageName: "hand.thumbsup.fill", active: vm.emoji?.isLike ?? false)
            }
        }
        .padding(.top, 72)
    }
    
    private func emojiButton(imageName: String, active: Bool) -> some View {
        Image(systemName: imageName)
            .resizable()
            .frame(width: 24, height: 24)
            .foregroundStyle(.white)
            .opacity(active ? 1 : 0.3)
            .frame(width: 69, height: 69)
            .background(
                Circle()
                    .foregroundStyle(.white.opacity(active ? 0.3 : 0.1))
            )
    }
    
    private var networkErrorView: some View {
        ErrorView(
            systemImageName: "wifi.exclamationmark",
            title: "네트워크 연결 상태를 확인해주세요",
            subTitle: "네트워크 연결 상태가 좋지 않아\n퀘스트를 불러올 수 없어요 ",
            emoticon: "🥲"
        ) {
            Task { await vm.getData() }
        }
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                withAnimation {
                    vm.handleDragChange(value)
                }
            }
            .onEnded { value in
                withAnimation {
                    vm.handleDragEnd(value, viewHeight)
                }
            }
    }
}

#Preview {
    ApprovalView()
}
