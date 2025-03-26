//
//  TermsAndPolicyView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/30/24.
//

import SwiftUI

struct TermsAndPolicyView: View {
    @State private var expandedItem: String? = nil
    
    let terms: [(title: String, date: String, fileName: String)] = [
        ("개인정보 처리방침", "2025.03.28", "2503_PRIVACY_POLICY"),
        ("서비스 이용약관", "2024.02.01", "2406_TERMS_OF_USE")
    ]
    
    var body: some View {
        StandardScreenView(title: "약관 및 정책") {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(terms, id: \..title) { term in
                        TermsListItem(
                            term: term,
                            isExpanded: expandedItem == term.title,
                            toggleExpansion: {
                                withAnimation {
                                    expandedItem = (expandedItem == term.title) ? nil : term.title
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

struct TermsListItem: View {
    let term: (title: String, date: String, fileName: String)
    let isExpanded: Bool
    let toggleExpansion: () -> Void
    
    private let pdfFrameHeight = 580.0
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: toggleExpansion) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(term.title)
                            .styledFont(.semibold, size: 16, lineHeight: 16)
                            .foregroundColor(.gray500)
                        Text(term.date)
                            .styledFont(.subTitle1)
                            .foregroundColor(.gray300)
                    }
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(Color.gray300)
                        .fontWeight(.medium)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color.white)
            
            if isExpanded {
                PDFKitView(fileName: term.fileName)
                    .frame(height: pdfFrameHeight)
            }
        }
    }
}

#Preview {
    TermsAndPolicyView()
}
