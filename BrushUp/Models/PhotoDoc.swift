//
//  PhotoDoc.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 4/1/26.
//
import Foundation
import FirebaseFirestore
struct PhotoDoc: Codable {
    let id: String
    let index: Int
    let filename: String
    let url: String
    let createdAt: Timestamp
    let tags: [String]
}
struct Index: Codable {
    let photo_index: Int
}
