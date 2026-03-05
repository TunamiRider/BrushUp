//
//  ImageInfo.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/19/26.
//
import Foundation
struct PhotoRecord: Codable, Sendable {
    let urls: Urls
    let width: Int
    let height: Int
}
struct Urls: Codable {
    let regular: String
    var regularUrl: URL { return URL(string: regular)!}
}
enum Orientation {
    case portrait, landscape, square
}

// This is an example case of protocol
//protocol DataSoruce{
//    associatedtype Response
//    typealias ResultHandler = (Result<Response, Error>) -> Void
//    func fethc(completion: @escaping ResultHandler)
//}
