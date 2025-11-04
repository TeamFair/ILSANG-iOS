//
//  ChangeNickNameView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/29/24.
//

import SwiftUI

struct ProfileEditView: View {
    @StateObject private var viewModel: ProfileEditViewModel
    @Environment(\.layout) var layout
    @Environment(\.dismiss) var dismiss
    
    private let profileImageSize: CGFloat = 80
    
    init(name: String, image: UIImage?, imageId: String?) {
        self._viewModel = StateObject(wrappedValue: ProfileEditViewModel(name: name, image: image, imageId: imageId, userNetwork: UserNetwork(), imageNetwork: ImageNetwork()))
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 36) {
                NavigationTitleView(title: "정보 수정") {
                    if viewModel.hasChanges {
                        viewModel.alertType = .CancleEditProfile
                        viewModel.showAlert.toggle()
                    } else {
                        dismiss()
                    }
                }
                .padding(.bottom, 8)
                .padding(.horizontal, -layout.horizontalPadding)
                
                profileImageSection
                nicknameInputSection
                Spacer()
                updateButton
            }
            .navigationBarBackButtonHidden()
            .padding(.horizontal, layout.horizontalPadding)
            .padding(.bottom, 8)
            
            if viewModel.showAlert {
                SettingAlertView(
                    alertType: viewModel.alertType,
                    onCancel: { viewModel.showAlert = false },
                    onConfirm: {
                        viewModel.handleAlertConfirm()
                        dismiss()
                    }
                )
            }
        }
        .sheet(isPresented: $viewModel.showEditProfileImageSheet) {
            editProfileImageSheet
                .presentationDetents([.height(200)])
                .presentationCornerRadius(24)
        }
        .cropImagePicker(show: $viewModel.showPhotosPicker, croppedImage: $viewModel.croppedImage)
    }
    
    
    private var profileImageSection: some View {
        VStack(spacing: 8) {
            Image(uiImage: viewModel.croppedImage ?? .profileCircle)
                .resizable()
                .scaledToFit()
                .frame(width: profileImageSize, height: profileImageSize)
                .clipShape(Circle())
            
            Button {
                viewModel.showEditProfileImageSheet.toggle()
            } label: {
                Text("프로필 사진 수정")
                    .foregroundStyle(.accentBlue)
                    .styledFont(.bold, size: 17, lineHeight: 22)
            }
        }
    }
    
    private var nicknameInputSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("새로운 닉네임을 입력하세요")
                .styledFont(.bold, size: 17, lineHeight: 22)
                .foregroundColor(.gray500)
                .padding(.bottom, 10)
            
            TextField("닉네임을 입력하세요", text: $viewModel.name)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.gray500)
                .frame(height: 22)
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.background)
                        .stroke(viewModel.nicknameError != nil ? Color.subRed : Color.clear, lineWidth: 2)
                        .frame(maxWidth: .infinity, maxHeight: 50)
                )
                .padding(.bottom, 12)
            
            if let error = viewModel.nicknameError {
                Text(error.rawValue)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.subRed)
            }
        }
    }
    
    
    private var updateButton: some View {
        PrimaryButton(title: "변경 완료", buttonAble: viewModel.buttonAble) {
            Task {
                let isSuccess = await viewModel.updateProfile()
                if isSuccess {
                    dismiss()
                }
            }
        }
    }
    
    private var editProfileImageSheet: some View {
        VStack(spacing: 0) {
            Text("프로필 사진 수정")
                .styledFont(.bold, size: 17, lineHeight: 22)
                .foregroundStyle(.black)
                .padding(.top, 26)
                .padding(.bottom, 15)
            
            Button {
                viewModel.showEditProfileImageSheet = false
                viewModel.showPhotosPicker.toggle()
            } label: {
                sheetButtonLabel(icon: .album, title: "갤러리에서 선택", color: .gray500)
            }
            
            Button {
                viewModel.alertType = .DeleteProfileImage
                viewModel.showEditProfileImageSheet = false
                viewModel.showAlert = true
                
            } label: {
                sheetButtonLabel(icon: .trash, title: "프로필 사진 삭제", color: .accentRed)
            }
            
            Spacer()
        }
    }
    
    private func sheetButtonLabel(icon: UIImage, title: String, color: Color)-> some View {
        HStack(spacing: 8) {
            Image(uiImage: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 22)
                .frame(width: 24, height: 24)
            Text(title)
                .styledFont(.subTitle2)
            Spacer()
        }
        .foregroundStyle(color)
        .frame(height: 65)
        .padding(.horizontal, 18)
    }
}

#Preview {
    ProfileEditView(name: "일상", image: .img0, imageId: "")
}


