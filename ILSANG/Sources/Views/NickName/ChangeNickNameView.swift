//
//  ChangeNickNameView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/29/24.
//

import SwiftUI

struct ChangeNickNameView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var name: String = ""
    @State private var isSame : Bool = false
    @State private var showAlert : Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                NavigationTitleView(title: "정보 수정") {
                    if name.isEmpty {
                        dismiss()
                    } else {
                        showAlert.toggle()
                    }
                }
                
                VStack (alignment: .leading, spacing: 0) {
                    //설명
                    Text("새로운 닉네임을 입력하세요")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.gray500)
                        .padding(.bottom, 10)
                    
                    //닉네임 입력란
                    TextField("닉네임을 입력하세요", text: $name)
                        .font(.system(size: 16, weight: .bold))         
                        .foregroundColor(.gray500)
                        .frame(height: 22)
                        .padding(14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .inset(by: 0.5)
                                .stroke(isSame ? Color.subRed : Color.clear, lineWidth: 2)
                                .frame(maxWidth: .infinity, maxHeight: 50)
                                .background(Color.background)
                                .cornerRadius(12)
                        )
                        .padding(.bottom, 12)
                    
                    Text("입력하신 닉네임은 이미 사용중이에요.\n다른 닉네임을 입력해주세요.")
                        .opacity(isSame ? 1 : 0)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.subRed)
                    
                    Spacer()
                    
                    PrimaryButton(title: "변경 완료", buttonAble: !isSame || !name.isEmpty) {
                        Task {
                            if await UserNetwork().putUser(nickname: name) {
                                withAnimation {
                                    dismiss()
                                }
                            } else {
                                // TODO: 중복인 경우(400번 에러)랑 다른 에러랑 구분해서 보여주도록 수정
                                //중복되는 아이디가 있거나 서버 연결에 문제 있을 경우
                                isSame = true
                            }
                        }
                    }
                }
                .navigationBarBackButtonHidden()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            }
            if showAlert {
                SettingAlertView(alertType: .NickName,onCancel: {showAlert = false}, onConfirm: {dismiss()})
            }
        }
    }
}
