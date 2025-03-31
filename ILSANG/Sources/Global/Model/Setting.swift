//
//  Setting.swift
//  ILSANG
//
//  Created by Kim Andrew on 5/29/24.
//

import SwiftUI

///arrow가 False일때 subInfo 작성
struct Setting : Identifiable, Hashable {
    let id = UUID()
    let title: String
    let titleColor: Color
    let type: SettingType
    
    init(title: String, titleColor: Color = .gray500, type: SettingType) {
        self.title = title
        self.titleColor = titleColor
        self.type = type
    }
}

enum SettingType: Hashable {
    case navigate
    case alert
    case info(String)
}

let openSource = """
Alamofire
Alamofire is an HTTP networking library written in Swift.
https://github.com/Alamofire/Alamofire
Copyright © 2014-2023 Alamofire Software Foundation (AFSF)
MIT License
"""
