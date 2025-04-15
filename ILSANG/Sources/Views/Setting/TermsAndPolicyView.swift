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
    
    private let pdfFrameHeight = 580.0
    
    var body: some View {
        StandardScreenView(title: "약관 및 정책") {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(terms, id: \.title) { term in
                        SettingToggleItemView(
                            title: term.title,
                            subtitle: term.date,
                            isExpanded: expandedItem == term.title,
                            toggleExpansion: {
                                withAnimation {
                                    expandedItem = (expandedItem == term.title) ? nil : term.title
                                }
                            }) {
                                PDFKitView(fileName: term.fileName)
                                    .frame(height: pdfFrameHeight)
                            }
                    }
                }
            }
        }
    }
}

#Preview {
    TermsAndPolicyView()
}
