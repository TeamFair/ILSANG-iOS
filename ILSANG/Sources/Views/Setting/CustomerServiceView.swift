//
//  CustomerServiceView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/30/24.
//

import SwiftUI
import UIKit

struct CustomerServiceView: View {
    
    var body: some View {
        StandardScreenView(title: "고객센터") {
            HStack {
                Text("인스타그램")
                    .styledFont(.semibold, size: 16, lineHeight: 16)
                    .foregroundColor(.gray500)
                Spacer()
                Text("illsang.official")
                    .underline()
                    .font(.system(size: 16))
                    .foregroundColor(.gray300)
            }
            .padding(20)
            .padding(.vertical, 4)
            .background(.white)
            .onTapGesture {
                openInstagram()
            }
        }
    }
    
    private func openInstagram() {
        //고객센터 인스타 URL
        let appURL = URL(string: "instagram://user?username=illsang.official")!
        let webURL = URL(string: "https://www.instagram.com/illsang.official?igsh=NjJjbXc3cmU3aG56")!
        
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL)
        }
    }
}

#Preview {
    CustomerServiceView()
}
