//
//  LoginView.swift
//  ILSANG
//
//  Created by Kim Andrew on 6/6/24.
//

import SwiftUI

struct LoginView: View {
    @StateObject var vm: LoginViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 100)

            titleView
            
            CarouselAutoSlideView(images: [.slide0, .slide1, .slide2, .slide3, .slide4])
                .shadow(color: .primaryPurple.opacity(0.2), radius: 10, x: 0, y: 4)
                .padding(.top, 48)
            
            Spacer(minLength: 88)
            
            VStack(spacing: 16) {
                LoginButtonView(channel: .google) {
                    vm.googleButtonAction()
                }
                
                AppleLoginButtonView { credential in
                    vm.loginWithApple(credential: credential)
                }
                .overlay {
                    LoginButtonView(channel: .apple) { }
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 60)
        .background(.white)
        .navigationBarBackButtonHidden()
    }
    
    private var titleView: some View {
        VStack(spacing: 2) {
            HStack(spacing: 0) {
                Text("일")
                    .foregroundColor(.primaryPurple)
                Text("상")
                    .foregroundColor(.secondaryGreen)
                Text("의 작은 행동이,")
            }
            Text("지역을 바꿉니다")
        }
        .styledFont(.title1)
        .foregroundColor(.black)
    }
}

#Preview {
    LoginView(vm: LoginViewModel())
}
