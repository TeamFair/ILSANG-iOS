//
//  AuthUser.swift
//  ILSANG
//
//  Created by Lee Jinhee on 7/10/24.
//

struct AuthUser {
    var accessToken: String
    var refreshToken: String
}

struct AuthResponse {
    var authToken: String
    var authUser: AuthUser
}
