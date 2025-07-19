//
//  PaintMeTests.swift
//  PaintMeTests
//
//  Created by Yuki Suzuki on 5/6/25.
//

import Testing
// import PaintMe
import BrushUp

import Foundation
import SwiftUI
struct BrushUpTests {
    // var tet = PaintMe.UnsplashImage.init();
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.

    }
    
    @Test @MainActor func testLoadDataValidURL() async throws {
        MockURLProtocol.responseData = mockJASON
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        

        let service = await FetchService();
        let result = try await service.loadData(endpoint: TestHelper.validURL)
        
        #expect(result.count == 1)
    }
    
    @Test @MainActor func testLoadDataInvalidURL() async throws {
        MockURLProtocol.error = NSError(domain: "", code: 0, userInfo: nil)
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: config)
        
        
        let service = await FetchService();
        let result = try await service.loadData(endpoint: TestHelper.inValidURL)
        
        #expect(result.count == 0)
        
    }
}

//Shared mock data
let mockJASON =
"""
[
{
    "id": "test123",
    "urls": { 
        "regular": "https://example.com/image.jpg"
    }
}
]
""".data(using: .utf8)!

extension BrushUpTests {
    actor TestHelper {
        static let validURL = "https://api.unsplash.com/photos/random?query=animal&count=1&client_id=sLxSdZB-s_jOnw_mPtaxMZADNpE_aoHQh-oWsoqrWrg"
        static let inValidURL = "not-a-url"
    }
}

class MockURLProtocol: URLProtocol {
    nonisolated(unsafe) static var responseData: Data?
    nonisolated(unsafe) static var error: Error?
    
    
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        if let error = MockURLProtocol.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        
        let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        
        client?.urlProtocol(self, didLoad: MockURLProtocol.responseData!)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
        
    }
}


