//
//  CustomerServiceView.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/30/24.
//

import SwiftUI
import UIKit

struct CustomerServiceView: View {
    private let settingList: [Setting] = [
        Setting(title: "인스타그램", type: .infoWithUnderLine("illsang.official")),
        Setting(title: "디스코드", type: .info("인스타그램 바이오링크 확인")),
        Setting(title: "이메일", type: .info("illsangtech@gmail.com"))
    ]
    
    var body: some View {
        StandardScreenView(title: "고객센터") {
            LazyVStack(spacing: 0) {
                ForEach(settingList) { item in
                    SettingItemView(item: item, action: {
                        if item.title == "인스타그램" {
                            openInstagram()
                        }
                    })
                }
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
