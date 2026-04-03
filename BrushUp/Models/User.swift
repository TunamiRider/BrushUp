//
//  User.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 3/30/26.
//

import Foundation
import FirebaseFirestore
struct User: Codable, FirestoreConvertible {
    let uid : String
    let isPremium: Bool
    let subscriptionId: String
    let createdAt: Date

    
    init(uid: String, createdAt: Date) {
        self.uid = uid
        self.isPremium = false
        self.subscriptionId = ""
        self.createdAt = createdAt
    }
    
    var dictionary: [String: Any]{
        return [
            "uid": uid,
            "isPremium": isPremium,
            "subscriptionId": subscriptionId,
            "createdAt": createdAt
        ]
    }
    
}


//{
//  email: "user@gmail.com",
//  isPremium: true,
//  subscriptionId: "...",
//  createdAt: ...
//}
