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
        ZStack {
            VStack(spacing: 28) {
                titleView
                CarouselAutoSlideView(images: [.slide0, .slide1, .slide2, .slide3, .slide4])
                    .shadow(color: .primaryPurple.opacity(0.2), radius: 10, x: 0, y: 4)
            }
            .offset(y: -80)
            
            VStack(spacing: 16) {
                Spacer()

                AppleLoginButtonView(vm: vm)
                // KakaoLoginButtonView(buttonAction: vm.kakaoButtonAction)
                // GoogleLoginButtonView(buttonAction: vm.googleButtonAction)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 38)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
