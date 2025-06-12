//
//  HonorInfoPopupView.swift
//  ILSANG
//
//  Created by Lee Jinhee on 5/14/25.
//

import SwiftUI

struct HonorInfoPopupView: View {
    let onClose: () -> ()

    var body: some View {
        VStack(spacing: 8) {
            Text("칭호")
                .styledFont(.heading3)
                .foregroundStyle(.black)
            Text("퀘스트를 수행하면 칭호가 쌓여요!")
                .styledFont(.caption2)
                .foregroundStyle(.gray400)
                .padding(.bottom, 24)
            HStack(spacing: 0) {
                ForEach(Array(HonorGrade.allCases.enumerated()), id: \.element) { index, grade in
                    VStack(spacing: 7) {
                        if let image = grade.image {
                            Image(uiImage: image)
                                .frame(30)
                        }
                        Text(grade.title)
                            .styledFont(.heading2)
                            .foregroundStyle(.black)
                        Text(grade.description)
                            .styledFont(.caption1)
                            .foregroundStyle(.gray400)
                    }
                    if index < HonorGrade.allCases.count - 1 {
                        dividerView
                    }
                }
            }
        }
        .padding(16)
        .overlay(alignment: .topTrailing) {
            Button {
                onClose()
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .frame(16)
                    .fontWeight(.thin)
                    .padding(16)
                    .foregroundStyle(.gray400)
            }
        }        
        .background(Color.white)
        .containerShape(RoundedRectangle(cornerRadius: 16))
    }
    
    private var dividerView: some View {
        RoundedRectangle(cornerRadius: 1)
            .frame(width: 1, height: 82)
            .foregroundStyle(.gray100)
            .padding(.horizontal, 10)
    }
}

#Preview {
    HonorInfoPopupView(onClose: {})
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.gray100)
}
