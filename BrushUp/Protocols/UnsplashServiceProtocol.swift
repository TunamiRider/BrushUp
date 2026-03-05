//
//  UnsplashServiceProtocol.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//

protocol UnsplashServiceProtocol {
    func fetchRandomPhoto() async throws -> [PhotoRecord]
    func fetchPhotos() async throws -> [PhotoRecord]
}
