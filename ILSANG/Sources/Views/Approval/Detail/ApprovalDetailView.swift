//
//  ApprovalDetailView.swift
//  ILLSANG
//
//  Created by Lee Jinhee on 12/6/25.
//

import SwiftUI

struct ApprovalDetailView: View {
    @StateObject var vm: ApprovalDetailViewModel
    @StateObject var userRouter: UserRouter
    @FocusState private var isCommentFocused: Bool
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            header  // 타이틀
            content
        }
        .background(Color.background)
        .navigationBarBackButtonHidden(true)
        .overlay { alertView }
        .task {
            vm.send(.load)
        }
        
        .scrollDismissesKeyboard(.immediately)
        .onTapGesture {
            vm.activeMissionHistoryMenu = false
            hideKeyboard()
        }
        .safeAreaInset(edge: .bottom) {
            inputView
        }
    }
    
    private var header: some View {
        NavigationTitleView(title: "인증 상세", isSeparatorHidden: true, background: .background) {
            dismiss()
        }
        .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
    }
    
    private var content: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ApprovalItemContentView(
                            id: vm.missionHistory.id,
                            title: vm.missionHistory.title,
                            image: vm.missionHistory.image,
                            nickname: vm.missionHistory.nickname,
                            userTitle: vm.missionHistory.userTitle,
                            profileImage: vm.missionHistory.profileImage,
                            displayDate: vm.missionHistory.displayDate,
                            commercialAreaName: vm.missionHistory.commercialAreaName,
                            width: .screenWidth - layout.horizontalPadding * 2,
                            height: ((.screenWidth-layout.horizontalPadding * 2) / 11) * 10,
                        ) {
                            vm.send(.profileTapped(userId: vm.missionHistory.userId))
                        }
                        .overlay(alignment: .topTrailing) {
                            trailingButton(for: vm.missionHistory)
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, layout.horizontalPadding)
                        .padding(.bottom, 16)
                        
                        ApprovalQuestView(
                            questType: vm.missionHistory.questType ?? .normal,
                            repeatType: vm.missionHistory.repeatType,
                            questTitle: vm.missionHistory.title,
                            writerName: vm.missionHistory.writer ?? "",
                            bgStyle: .roundedStroke,
                            status: vm.missionHistory.questStatus,
                            action: {
                                vm.send(.mission)
                            }
                        )
                        .padding(.bottom, 32)
                        .padding(.horizontal, layout.horizontalPadding)
                        
                        HStack(spacing: 4) {
                            Text("댓글")
                                .foregroundStyle(.black)
                                .styledFont(.heading1)
                            Text("\(vm.comments.count)")
                                .foregroundStyle(.gray500)
                                .styledFont(.body)
                            Spacer()
                        }
                        .padding(.bottom, 8)
                        .padding(.horizontal, layout.horizontalPadding)
                    }
                    .background(Color.white)
                    
                    divider
                    
                    if vm.comments.isEmpty {
                        emptyCommentView
                    } else {
                        LazyVStack(spacing: 0) {
                            ForEach(Array(vm.comments.enumerated()), id: \.offset) { idx, comment in
                                CommentView(
                                    activeMenuCommentId: $vm.activeMenuCommentId,
                                    comment: comment) { action in
                                        vm.send(.commentAction(action))
                                    }
                                    .overlay(alignment: .bottom) {
                                        if idx != CommentItem.mockList.count - 1 {
                                            divider
                                        }
                                    }
                                    .id(comment.id)
                            }
                        }
                    }
                }
                .cornerRadius(12, corners: [.topLeft, .topRight])
            }
            .onReceive(vm.$event) { event in
                guard let event else { return }
                switch event {
                case .scrollToComment(let id):
                    withAnimation(.linear) {
                        proxy.scrollTo(id, anchor: .bottom)//.init(x: 0.5, y: 0.8))
                    }
                case .focusCommentField:
                    isCommentFocused = true
                }
            }
            .padding(.bottom, -10)
            .padding(.horizontal, layout.horizontalPadding)
            .overlay {
                if vm.activeMenuCommentId != nil || vm.activeMissionHistoryMenu {
                    Color.clear
                        .contentShape(Rectangle()) // 터치 영역 확보
                        .onTapGesture {
                            vm.activeMissionHistoryMenu = false
                            vm.activeMenuCommentId = nil
                        }
                        .gesture(
                            DragGesture().onChanged { _ in
                                vm.activeMissionHistoryMenu = false
                                vm.activeMenuCommentId = nil
                            }
                        )
                }
            }
        }
    }
    
    private func trailingButton(for item: ApprovalMissionHistoryItem) -> some View {
        Button {
            withAnimation(.snappy) {
                vm.send(.missionHistoryEllipsisTapped)
            }
        } label: {
            Image(.moreVertical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray500)
                .frame(height: 35)
        }
        .overlay(alignment: .topTrailing) {
            if vm.activeMissionHistoryMenu {
                CommentMenuOverlay(
                    canDelete: false,
                    canReport: true,
                    onDelete: { },
                    onReport: {
                        vm.send(.missionHistoryReport)
                    }
                )
                .padding(.top, 40)
            }
        }
    }
    
    private var inputView: some View {
        VStack(spacing: 0) {
            if let (_, nickname) = vm.replyingToComment {
                HStack {
                    Text("\(nickname)님께 답글 남기는 중")
                        .styledFont(.caption2)
                        .foregroundStyle(.primaryPurple)
                    Spacer(minLength: 0)
                    Button {
                        vm.replyingToComment = nil
                    } label: {
                        Text("취소")
                            .styledFont(.caption2)
                            .foregroundStyle(.gray400)
                            .frame(height: 30)
                    }
                }
                .padding(.horizontal, layout.horizontalPadding)
                .background(Color.primary100)
            }
            
            divider
            
            HStack(spacing: 8) {
                HStack(spacing: 10) {
                    TextField("", text: $vm.comment, axis: .vertical)
                        .styledFont(.caption1)
                        .submitLabel(.return)
                        .keyboardType(.default)
                        .foregroundStyle(.black)
                        .focused($isCommentFocused)
                        .overlay(alignment: .leading) {
                            if vm.comment.isEmpty {
                                Text("댓글을 입력해 주세요.")
                                    .styledFont(.caption1)
                                    .foregroundStyle(.gray300)
                                    .padding(.leading, 2)
                                    .allowsHitTesting(false)
                            }
                        }
                    Text("\(vm.comment.count)/\(vm.maxCommentLength)")
                        .styledFont(.tabBold)
                        .foregroundStyle(.gray300)
                }
                .padding(.vertical, 13)
                .padding(.horizontal, 16)
                .frame(minHeight: 50, alignment: .leading)
                .roundedBackground(cornerRadius: 12, bgColor: .gray100)
                
                Button {
                    vm.send(.createComment)
                } label: {
                    Text("등록")
                        .styledFont(.button)
                        .foregroundStyle(.white)
                        .frame(width: 70, height: 50)
                        .roundedBackground(cornerRadius: 12, bgColor: vm.comment.isEmpty ? .gray300 : .primaryPurple)
                }
                .disabled(vm.comment.isEmpty)
            }
            .frame(maxHeight: 90, alignment: .top)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.vertical, 11)
        }
        .background(Color.white)
    }
    
    private var emptyCommentView: some View {
        Text("댓글이 아직 없어요.")
            .styledFont(.subTitle2)
            .foregroundStyle(.gray500)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 60)
    }
    
    private var divider: some View {
        Rectangle()
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.gray100)
    }
    
    @ViewBuilder
    private var alertView: some View {
        if let alertType = vm.showAlertType {
            SettingAlertView(
                alertType: alertType,
                onCancel: nil,
                onConfirm: { vm.showAlertType = nil }
            )
        }
    }
}

#Preview {
    //    ApprovalDetailView(
    //        vm: ,
    //        userRouter:
    //    )
}
