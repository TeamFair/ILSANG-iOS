//
//  ChallengeDetailView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/31/24.
//

import SwiftUI

struct UserMissionHistoryDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var vm: UserMissionHistoryViewModel
    
    let missionHistory: UserMissionHistoryItem
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationTitleView(title: "챌린지 정보", isSeparatorHidden: true) {
                dismiss()
            }
            .overlay(alignment: .trailing) {
                trailingButton /// 공유 & 삭제 버튼
            }
            .padding(.bottom, 8) // 세로로 긴 이미지 대응 (NavigationTitleView의 bottom 패딩과 겹침)
            
            ScrollView {
                VStack(spacing: 0) {
                    if let detailItem = vm.selectedMissionHistoryDetail {
                        switch missionHistory.missionType {
                        case .quiz(let quizType):
                            
                            UserMissionHistoryInfoView(missionHistory: detailItem)
                            if let quiz = detailItem.quizList?.first {
                                UserMissionHistoryInfoSectionView(
                                    quizType: quizType,
                                    question: quiz.question,
                                    answer: quiz.answers.joined(separator: " "),
                                    userAnswer: quiz.userAnswer,
                                    metroPoint: detailItem.metroGainPoint,
                                    commercialPoint: detailItem.commercialGainPoint,
                                    contributionPoint: detailItem.contributionGainPoint,
                                    writer: detailItem.writerName,
                                    createdAt: detailItem.createdAt.timeAgoCreatedAt()
                                )
                            }
                        case .photo:
                            SubmittedImageView(image: detailItem.submitImage)
                            UserMissionHistoryInfoView(missionHistory: detailItem)
                            UserMissionHistoryInfoSectionView(
                                metroPoint: detailItem.metroGainPoint,
                                commercialPoint: detailItem.commercialGainPoint,
                                contributionPoint: detailItem.contributionGainPoint,
                                writer: detailItem.writerName,
                                createdAt: detailItem.createdAt.timeAgoCreatedAt()
                            )
                        }
                    }
                }
            }
        }
        .background(Color.background)
        .navigationBarBackButtonHidden()
        .task {
            await vm.fetchMissionHistoryDetail(
                id: missionHistory.missionHistoryId,
                submitImage: missionHistory.submitImage
            )
        }
        .overlay {
            if vm.challengeDelete {
                SettingAlertView(
                    alertType: AlertType.ChallengeDelete,
                    onCancel: { vm.challengeDelete = false },
                    onConfirm: {
                        Task {
                            if await vm.deleteMissionHistory(id: missionHistory.missionHistoryId) {
                                vm.challengeDelete = false
                                dismiss()
                            } else {
                                vm.challengeDelete = false
                            }
                        }
                    }
                )
            }
        }
    }
    
    
    private var errorView: some View {
        ErrorView(title: "챌린지 정보를 불러오지 못했어요", subTitle: "챌린지 정보를 불러오는 데 실패했어요.\n인터넷 연결 상태 확인 후 다시 시도해주세요.") {
            Task {
                if let submitImageId = missionHistory.submitImageId {
                    missionHistory.submitImage = await vm.getImage(imageId: submitImageId)
                }
            }
        }
    }
    
    private var trailingButton: some View {
        Menu {
            if missionHistory.missionType == .photo {
                ShareLink(item: photo, preview: SharePreview(photo.caption, image: photo.image)) {
                    Label("공유하기", image: "share")
                }
            }
            Button {
                vm.challengeDelete.toggle()
            } label: {
                Label("삭제하기", image: "trash")
            }
            .foregroundStyle(.gray500)
        } label: {
            Image(.moreVertical)
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.gray500)
        }
        .padding(.trailing, 12)
    }
    
    // MARK: - 챌린지 이미지 공유하기
    private var photo: TransferableUIImage {
        return .init(uiimage: dailyShareUIImage, caption: "일상 챌린지 공유하기")
    }
    
    private var dailyShareUIImage: UIImage {
        let renderer = ImageRenderer(
            content: SubmittedImageView(image: missionHistory.submitImage ?? .logo).frame(width: 440) // FIXME: 공유 이미지 변경
        )
        renderer.scale = 3.0
        return renderer.uiImage ?? .init()
    }
}

struct SubmittedImageView: View {
    let image: UIImage?
    
    var body: some View {
        VStack(spacing: 0) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct UserMissionHistoryInfoView: View {
    let missionHistory : UserMissionHistoryDetailItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(missionHistory.createdAt.timeAgoSinceDate() + " 에 포인트 획득 완료!")
                .styledFont(.tabBold)
                .foregroundColor(.primaryPurple)
            
            Text(missionHistory.title.forceCharWrapping)
                .styledFont(.title1)
                .foregroundColor(.black)
            
            MissionTagGroupView(
                questType: missionHistory.questType,
                repeatType: missionHistory.repeatType,
                missionType: missionHistory.missionType
            )
            
            if missionHistory.missionType == .photo {
                ReactionView(likeCount: missionHistory.likeCount)
                    .padding(.top, 12)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(.white)
    }
}

struct UserMissionHistoryInfoSectionView: View {
    var quizType: QuizType? = nil
    var question: String? = nil
    var answer: String? = nil
    var userAnswer: String? = nil
    let metroPoint: Int
    let commercialPoint: Int
    let contributionPoint: Int
    let writer: String
    let createdAt: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let quizType {
                quizView(quizType)
            }
            
            UserMissionHistoryInfoSection(
                title: "획득한 포인트",
                content:
                    VStack(spacing: 8) {
                        reward(title: "일상지역", metroPoint)
                        reward(title: "일상존", commercialPoint)
                        reward(title: "기여도", contributionPoint)
                    }
            )
            
            UserMissionHistoryInfoSection(
                title: "작성자 정보",
                content:
                    Text(writer)
                    .styledFont(.subTitle2)
                    .foregroundColor(.black)
            )
            
            UserMissionHistoryInfoSection(
                title: "퀘스트 수행 날짜",
                content:
                    Text(createdAt)
                    .styledFont(.subTitle2)
                    .foregroundColor(.black)
            )
        }
        .padding(20)
        .padding(.bottom, 72)
        .background(Color.background)
    }
    
    private func quizView(_ type: QuizType) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            QuizQuestionView(question: question ?? "")
            
            switch type {
            case .text:
                VStack(alignment: .leading, spacing: 8) {
                    Text("내 정답")
                        .styledFont(.heading2)
                        .foregroundColor(.primaryPurple)
                    Text(userAnswer?.forceCharWrapping ?? "")
                        .styledFont(.subTitle2)
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                }
            case .ox:
                HStack(spacing: 10) {
                    OXSelectionLabel(label: "O", isSelected: answer == "O")
                    OXSelectionLabel(label: "X", isSelected: answer == "X")
                }
            }
            
            Text("정답: \(answer ?? "")")
                .styledFont(.caption1)
                .foregroundColor(.primary500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .roundedBackground(cornerRadius: 12)
    }

    private func reward(title: String, _ point: Int) -> some View {
        HStack {
            Text(title)
                .styledFont(.subTitle2)
                .foregroundColor(.gray500)
            Spacer()
            Text("+\(point)P")
                .styledFont(.title2)
                .foregroundColor(.primaryPurple)
        }
    }
}

struct UserMissionHistoryInfoSection<Content: View>: View {
    let title: String
    let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .styledFont(.tabBold)
                .foregroundColor(.gray500)
            
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .roundedBackground(cornerRadius: 12)
        .shadow(color: .shadow7D.opacity(0.05), radius: 20, x: 0, y: 10)
    }
}

struct MissionTagGroupView: View {
    let questType: QuestType?
    let repeatType: RepeatType?
    let missionType: MissionType
    
    var body: some View {
        HStack(spacing: 4) {
            if let tagConfig = tagConfig(for: questType) {
                TagView(
                    title: tagConfig.title,
                    image: tagConfig.image,
                    tagStyle: tagConfig.style
                )
            }
            
            TagView(
                title: missionType.description,
                tagStyle: .approvalType
            )
        }
    }
    
    private func tagConfig(for type: QuestType?) -> TagConfig? {
        switch type {
        case .normal:
            return nil
        case .repeat:
            if let repeatType {
                return TagConfig(
                    style: .repeat(repeatType),
                    image: nil,
                    offset: (0, 0),
                    title: repeatType.description
                )
            } else {
                return nil
            }
        case .event:
            return TagConfig(
                style: .eventWithIcon,
                image: .event,
                offset: (0, 0),
                title: "한정"
            )
        case .none:
            return nil
        }
    }
}

#Preview {
    SubmittedImageView(
        image: .img0
    )
}
