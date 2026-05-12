//
//  UnsplashServiceTests.swift
//  BrushUp
//
//  Created by Yuki Suzuki on 5/5/26.
//

import Testing
import BrushUp
import SwiftUI
import Foundation
struct UnsplashServiceTests {

    
    @Test @MainActor func testFetchRandomPhoto() async throws {
        let fetchService = FetchService()
        //let deviceID = UIDevice.current.identifierForVendor!.uuidString
        let firebaseService = FirebaseService()
        
        
        let unsplashService = UnsplashService(fetchService: fetchService, firebaseService: firebaseService)
        
        let photos = try await unsplashService.fetchRandomPhoto()
        
        #expect(!photos.isEmpty, "✅ fetchRandomPhoto returned photos successfully")
        #expect(photos.count == 1, "✅ Expected exactly 1 photo, got \(photos.count)")
    }
    
}
