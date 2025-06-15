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
                .padding(.top, 40)
            
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
        .padding(.bottom, 38)
        .background(.white)
        .navigationBarBackButtonHidden()
    }
    
    private var titleView: some View {
        VStack {
            Text("특별한 하루를 위한")
            HStack(spacing: 0) {
                Text("작은 도전, ")
                Text("일")
                    .foregroundColor(.primaryPurple)
                Text("상")
                    .foregroundColor(.secondaryGreen)
                Text("!")
            }
            .foregroundColor(.black)
        }
        .font(.system(size: 23, weight: .bold))
    }
}

#Preview {
    LoginView(vm: LoginViewModel())
}
