//
//  ApprovalItemContentView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 3/1/25.
//


import SwiftUI

/// 18 버전 미만 > 시트로 이미지 확대 표시
/// 18 버전 이상 > 네비게이션 이동(zoom 효과)
struct ApprovalItemContentView: View, Equatable {
    static func == (lhs: ApprovalItemContentView, rhs: ApprovalItemContentView) -> Bool {
        lhs.id == rhs.id
    }
    
    @Namespace var namespace
    @State var showMagView: Bool = false
    @State var showSheetView: Bool = false
    
    let id: Int
    let title: String
    let image: UIImage?
    let nickname: String
    let userTitle: UserTitle?
    let profileImage: UIImage?
    let displayDate: String
    let commercialAreaName: String?
    let width: CGFloat
    let height: CGFloat
    
    let onOtherUserTapped: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Button {
                onOtherUserTapped()
            } label: {
                ProfileView(profileImage: profileImage, nickname: nickname, honor: userTitle)
            }
            
            Text(title)
                .styledFont(.title1)
                .foregroundStyle(.black)
            
            if #available(iOS 18.0, *) {
                Image(uiImage: image ?? .logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .matchedTransitionSource(id: id, in: namespace)
                    .onTapGesture {
                        showMagView.toggle()
                    }
            } else {
                Image(uiImage: image ?? .logo)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: height)
                    .clipped()
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onTapGesture {
                        showSheetView.toggle()
                    }
            }
            
            MetadataView(displayDate: displayDate, commercialAreaName: commercialAreaName)
        }
        .sheet(isPresented: $showSheetView) {
            ImageFullScreenView(image: image ?? .logo) {
                showSheetView.toggle()
            }
        }
        .sheet(isPresented: $showMagView) {
            if #available(iOS 18.0, *) {
                ImageFullScreenView(image: image ?? .logo) {
                    showMagView.toggle()
                }
                .navigationTransition(.zoom(sourceID: id, in: namespace))
            } else {
                ImageFullScreenView(image: image ?? .logo) {
                    showMagView.toggle()
                }
            }
        }
    }
}

struct ApprovalItemContentShareView: View {
    let item: ApprovalMissionHistoryItem
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ProfileView(profileImage: item.profileImage, nickname: item.nickname, honor: item.userTitle)
            
            Text(item.title)
                .styledFont(.title1)
                .foregroundStyle(.black)
            
            Image(uiImage: item.image ?? .logo)
                .resizable()
                .scaledToFill()
                .frame(width: width, height: height)
                .clipped()
                .contentShape(RoundedRectangle(cornerRadius: 12))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            MetadataView(displayDate: item.displayDate, commercialAreaName: item.commercialAreaName)
            
            ReactionView(likeCount: item.likeCount, hateCount: item.hateCount)
        }
        .background(.white)
    }
}

fileprivate struct ProfileView: View {
    let profileImage: UIImage?
    let nickname: String
    let honor: UserTitle?
    
    var body: some View {
        HStack(spacing: 10) {
            Image(uiImage: profileImage ?? .profileCircle)
                .resizable()
                .frame(width: 35, height: 35)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                Text(nickname)
                    .font(.system(size: 14, weight: .semibold))
                
                if let honor {
                    HonorIconView(
                        honorTitle: honor.name,
                        grade: honor.grade,
                        imageSize: 20,
                        spacing: 4,
                        font: .badge1,
                        fgColor: .gray500
                    )
                }
            }
        }
        .foregroundStyle(.gray500)
    }
}

fileprivate struct MetadataView: View {
    let displayDate: String
    let commercialAreaName: String?
    
    var body: some View {
        HStack(spacing: 4) {
            Text(displayDate)
                .font(.system(size: 12, weight: .regular))
            
            Spacer(minLength: 0)
            
            if let commercialAreaName, !commercialAreaName.isEmpty {
                Image(.illsangRegion)
                    .resizable()
                    .scaledToFit()
                    .frame(18)
                
                Text(commercialAreaName)
                    .styledFont(.badge1)
            }
        }
        .foregroundStyle(.gray500)
    }
}

struct ReactionView: View, Equatable {
    static func == (lhs: ReactionView, rhs: ReactionView) -> Bool {
        lhs.likeCount == rhs.likeCount &&
        lhs.hateCount == rhs.hateCount
    }
    
    let likeCount: Int
    var hateCount: Int? = nil
    
    var body: some View {
        HStack(spacing: 16) {
            emojiView(imageName: .thumbsUp, count: likeCount, alignment: .top)
            if let hateCount {
                emojiView(imageName: .thumbsDown, count: hateCount, alignment: .bottom)
            }
        }
    }
    
    private func emojiView(imageName: UIImage, count: Int, alignment: Alignment) -> some View {
        HStack(spacing: 4) {
            Image(uiImage: imageName)
                .resizable()
                .renderingMode(.template)
                .scaledToFit()
                .frame(width: 21, height: 21)
                .foregroundStyle(.gray200)
                .frame(width: 24, height: 24, alignment: alignment)
            Text("\(count)")
                .monospacedDigit()
                .styledFont(.heading2)
                .foregroundStyle(.gray300)
        }
        .frame(height: 24)
    }
}


#Preview {
    let item1 = ApprovalMissionHistoryItem.mockDataList[0]
    let item2 = ApprovalMissionHistoryItem.mockDataList[1]
    ScrollView {
        ApprovalItemContentView(
            id: item1.id,
            title: item1.title,
            image: item1.image,
            nickname: item1.nickname,
            userTitle: item1.userTitle,
            profileImage: item1.profileImage,
            displayDate: item1.displayDate,
            commercialAreaName: item1.commercialAreaName,
            width: .screenWidth-40,
            height:  ((.screenWidth-40) / 5) * 4,
            onOtherUserTapped: { }
        )
        
        ApprovalItemContentView(
            id: item2.id,
            title: item2.title,
            image: item2.image,
            nickname: item2.nickname,
            userTitle: item2.userTitle,
            profileImage: item2.profileImage,
            displayDate: item2.displayDate,
            commercialAreaName: item2.commercialAreaName,
            width: .screenWidth-40,
            height:  ((.screenWidth-40) / 5) * 4,
            onOtherUserTapped: { }
        )
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .padding()
    .background(Color.background)
}
