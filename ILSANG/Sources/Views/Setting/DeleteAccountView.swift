//
//  DeleteAccountView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/30/24.
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) var dismiss

    @State private var isChecked = false
    @State private var delAlert = false
    @State private var showErrorAlert = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                NavigationTitleView(title: "회원 탈퇴", isSeparatorHidden: true) {
                    dismiss()
                }
                
                VStack(alignment: .center, spacing: 10){
                    
                    Spacer()
                    
                    Text("🚨")
                        .font(.system(size: 50))
                        .frame(width: 60, height: 60)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 92, height: 92)
                        .cornerRadius(26)
                    
                    Text("일상 탈퇴 전 확인하세요!")
                        .foregroundColor(.black)
                        .font(.system(size: 23))
                        .fontWeight(.bold)
                        .padding(.bottom, 11)

                    Text("탈퇴하시면 모든 데이터는 복구가 불가능합니다.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.gray400)
                        .padding(.bottom, 35)

                    
                    Text("• 진행 및 완료된 모든 퀘스트 내용이 삭제됩니다.\n• 경험치 및 레벨은 복구가 불가합니다.")
                        .font(.system(size: 14))
                        .foregroundColor(Color.gray400)
                        .multilineTextAlignment(.leading)
                        .lineSpacing(4)
                        .padding(.horizontal, 13)
                        .padding(.vertical, 15)
                        .background(Rectangle().foregroundColor(.gray100))
                        .cornerRadius(12)
                    
                    Spacer()
         
                    Button {
                        isChecked.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: isChecked ? "checkmark.circle" : "circle")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .scaledToFit()
                                .foregroundColor(isChecked ? Color.accentColor : Color.gray200)
                            Text("안내사항을 모두 확인하였으며, 이에 동의합니다.")
                                .font(.system(size: 15))
                                .foregroundColor(Color.gray400)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 21)
                    }
                    .padding(.bottom, 20)
                
                    Button {
                        delAlert.toggle()
                    } label: {
                        Text("탈퇴하기")
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.white)
                            .frame(height: 50)
                            .frame(maxWidth: .infinity)
                            .background(isChecked ? Color.accentColor : Color.gray300)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20).padding(.bottom, 42)
                    .disabled(!isChecked)
                    .alert(Text("회원탈퇴에 실패했습니다"), isPresented: $showErrorAlert) {
                        Button("확인") {
                            showErrorAlert.toggle()
                        }
                    }
                }
            }
            
            if delAlert {
                SettingAlertView(
                    alertType: .Withdrawal,
                    onCancel: { delAlert = false },
                    onConfirm: { withdraw() }
                )
            }
        }
        .frame(maxWidth: .infinity)
        .navigationBarBackButtonHidden()
    }
    
    private func withdraw() {
        Task {
            let result = await WithdrawNetwork().getWithdraw()
            switch result {
            case .success:
                await UserService.shared.withdraw()
                delAlert = false
            case .failure:
                delAlert = false
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    DeleteAccountView()
}
