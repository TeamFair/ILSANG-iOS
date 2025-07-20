//
//  NavigationTitleView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/30/24.
//

import SwiftUI

struct NavigationTitleView: View {
    let title: String
    var isSeparatorHidden = false
    var isDismissButtonHidden = false
    var background: Color = .white
    var action: (() -> Void?)? = nil

    var body: some View {
        VStack(spacing: 0) {
            Text(title)
                .frame(maxWidth: .infinity)
                .overlay(alignment: .leading) {
                    if !isDismissButtonHidden {
                        Button {
                            self.action?()
                        } label: {
                            DismissButton()
                        }
                    }
                }
                .foregroundColor(.black)
                .font(.system(size: 17, weight: .bold))
                .padding(.horizontal, 20)
                .frame(height: 45)
                .background(background)
            
            if !isSeparatorHidden {
                SeparatorView()
            }
        }
        .padding(.bottom, -8)
    }
}

struct SeparatorView: View {
    var body: some View {
        Rectangle()
            .frame(maxWidth: .infinity)
            .frame(height: 0.5)
            .foregroundStyle(Color.grayDD)
    }
}

// TODO: 수정
struct XmarkButton: View {
    var body: some View {
        Image(systemName: "xmark")
            .foregroundColor(.gray500)
            .font(.system(size: 22))
    }
}

struct DismissButton: View {
    var body: some View {
        Image(systemName: "chevron.left")
            .foregroundColor(.gray500)
            .font(.system(size: 22))
    }
}

struct DeleteButton: View {
    var body: some View {
        Image(systemName: "trash")
            .foregroundColor(.gray500)
            .font(.system(size: 22))
            .padding(.top, 10)
            .padding(.horizontal, 15)
    }
}
