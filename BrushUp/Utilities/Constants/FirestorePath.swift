//
//  FirestorePath.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//

import Foundation
enum FirestorePath {
    static let history = "users/%@/history"
    static let unsplashApiKey = "config/unsplash_api_key"
    
    static func history(for deviceID: String) -> String {
        return String(format: FirestorePath.history, deviceID)
    }
}
