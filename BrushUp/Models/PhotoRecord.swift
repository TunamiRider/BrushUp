//
//  ImageInfo.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/19/26.
//
import Foundation
public struct PhotoRecord: Codable, Sendable {
    let urls: Urls
    let width: Int
    let height: Int
    // let user: User?
}
struct Urls: Codable {
    let regular: String
    var regularUrl: URL { return URL(string: regular)!}
}
enum Orientation {
    case portrait, landscape, square
}
//new data
//struct User: Codable {
//    let profileImage: ProfileImage?
//    let instagramUsername: String?  // ✅ Add this - it's top-level!
//    let social: Social?
//}
//
//struct ProfileImage: Codable {
//    let small: String?
//    let medium: String?
//    let large: String?
//}
//struct Social: Codable {
//    let instagramUsername: String?
//}



// This is an example case of protocol
//protocol DataSoruce{
//    associatedtype Response
//    typealias ResultHandler = (Result<Response, Error>) -> Void
//    func fethc(completion: @escaping ResultHandler)
//}
