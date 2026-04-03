//
//  FirestorePath.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//

import Foundation
enum FirestorePath {
    static let users = "users/%@"
    static let history = "users/%@/history"
    static let unsplashApiKey = "config/unsplash_api_key"
    static let toPhoto_index = "/config/index"
    static let toPhotosCollection = "photos"
    
    static func history(for deviceID: String) -> String {
        return String(format: FirestorePath.history, deviceID)
    }
    static func users_path(for uid: String) -> String {
        return String(format: FirestorePath.users, uid)
    }
    
}

enum FirestoreField {
    static let index = "index"
    static let tags = "tags"
    
}
