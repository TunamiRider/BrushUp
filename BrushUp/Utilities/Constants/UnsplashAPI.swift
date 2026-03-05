//
//  UnsplashAPI.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 2/21/26.
//

import Foundation
enum UnsplashAPI {
    private static let baseEndpoint = "https://api.unsplash.com/photos/random"
    private static let baseQuery = "?query=[tag]"
    private static let countQuery = "&count=[count]"
    private static let clientIdQuery = "&client_id=[apiKey]"

    static func apiEndpoint(with tag: String, apiKey: String, count: Int) -> String {
        let query = baseQuery.replacingOccurrences(of: "[tag]", with: tag)
        let count = countQuery.replacingOccurrences(of: "[count]", with: String(count))
        let auth = clientIdQuery.replacingOccurrences(of: "[apiKey]", with: apiKey)
        return baseEndpoint + query + count + auth
    }
    static func apiEndpoint(apiKey: String, count: Int) -> String {
        var count = countQuery.replacingOccurrences(of: "[count]", with: String(count))
        count = count.replacingOccurrences(of: "&", with: "?")
        let auth = clientIdQuery.replacingOccurrences(of: "[apiKey]", with: apiKey)
        return baseEndpoint + count + auth
    }
}

enum Secrets {
    static var apiKey: String {
        return Bundle.main.object(forInfoDictionaryKey: "UNSPLASH_API_KEY") as? String ?? ""
    }
}
